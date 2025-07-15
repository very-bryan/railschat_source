class ChannelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_channel, only: [:show, :members, :update_members, :toggle_favorite, :mentionable_users]
  
  def index
    @channels = current_user.channels.includes(:channel_members, :messages)
    @all_users = User.where.not(id: current_user.id)
    
    respond_to do |format|
      format.html
      format.json do
        render json: @channels.map { |channel| 
          {
            id: channel.id,
            name: channel.name,
            is_private: channel.is_private,
            users_count: channel.users.count
          }
        }
      end
    end
  end

  def show
    @messages = @channel.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
  end

  def create
    @channel = Channel.new(channel_params)
    @channel.workspace = current_user.current_workspace
    
    if @channel.save
      @channel.channel_members.create(user: current_user, role: 'admin')
      
      if params[:channel][:member_ids].present?
        user_ids = params[:channel][:member_ids].reject(&:blank?)
        user_ids.each do |user_id|
          @channel.channel_members.create(user_id: user_id, role: 'member')
        end
      end
      
      respond_to do |format|
        format.html { redirect_to chat_channel_path(@channel), notice: "채널이 생성되었습니다." }
        format.turbo_stream { redirect_to chat_channel_path(@channel), notice: "채널이 생성되었습니다." }
      end
    else
      respond_to do |format|
        format.html do
          @channels = current_user.channels.includes(:channel_members, :messages)
          @all_users = User.where.not(id: current_user.id)
          render 'index', alert: "채널 생성에 실패했습니다."
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("channel_form_errors", 
            partial: "channels/form_errors", 
            locals: { channel: @channel })
        end
      end
    end
  end

  def members
    # Get current channel members with roles
    current_members = @channel.channel_members.includes(:user).map do |member|
      {
        id: member.user.id,
        name: member.user.name || member.user.email.split('@').first,
        email: member.user.email,
        avatar_url: member.user.avatar_url,
        role: member.role,
        # Only allow removal if not the current user and not admin
        can_remove: member.user.id != current_user.id && member.role != 'admin'
      }
    end.sort_by { |m| m[:role] == 'admin' ? 0 : 1 }
    
    # Get available members from workspace
    workspace = @channel.workspace || current_user.current_workspace
    all_workspace_users = workspace.users
    channel_member_ids = @channel.users.pluck(:id)
    
    available_members = all_workspace_users
                          .where.not(id: channel_member_ids)
                          .map do |user|
      {
        id: user.id,
        name: user.name || user.email.split('@').first,
        email: user.email,
        avatar_url: user.avatar_url
      }
    end
    
    render json: {
      current_members: current_members,
      available_members: available_members
    }
  end

  def update_members
    add_member_ids = params[:add_member_ids] || []
    remove_member_ids = params[:remove_member_ids] || []
    
    Rails.logger.info "=== Update Members ==="
    Rails.logger.info "Add member IDs: #{add_member_ids.inspect}"
    Rails.logger.info "Remove member IDs: #{remove_member_ids.inspect}"
    Rails.logger.info "Channel: #{@channel.id}, Current members: #{@channel.users.pluck(:id)}"
    
    # Add new members
    add_member_ids.each do |user_id|
      user = User.find_by(id: user_id)
      Rails.logger.info "Adding user #{user_id}: #{user.inspect}"
      
      if user && !@channel.users.include?(user)
        member = @channel.channel_members.create(user: user, role: 'member')
        Rails.logger.info "Created member: #{member.inspect}, errors: #{member.errors.full_messages}"
      else
        Rails.logger.info "User not found or already a member"
      end
    end
    
    # Remove members (but not the current user)
    remove_member_ids.each do |user_id|
      next if user_id.to_i == current_user.id
      
      member = @channel.channel_members.find_by(user_id: user_id)
      member&.destroy
    end
    
    render json: { 
      status: 'ok',
      updated_member_count: @channel.users.count,
      current_member_ids: @channel.users.pluck(:id)
    }
  end
  
  def toggle_favorite
    begin
      Rails.logger.info "=== Toggle Favorite Request ==="
      Rails.logger.info "Channel ID: #{@channel.id}"
      Rails.logger.info "User ID: #{current_user.id}"
      Rails.logger.info "User Email: #{current_user.email}"
      Rails.logger.info "Channel Members: #{@channel.users.pluck(:email).join(', ')}"
      
      # Check if user is a member of the channel
      unless @channel.users.include?(current_user)
        Rails.logger.error "User #{current_user.email} is not a member of channel #{@channel.name}"
        render json: { 
          status: 'error',
          error: '채널 멤버만 즐겨찾기를 할 수 있습니다.' 
        }, status: :forbidden
        return
      end
      
      # Use find_or_initialize_by to avoid race conditions
      favorite = current_user.channel_favorites.find_or_initialize_by(channel_id: @channel.id)
      
      if favorite.persisted?
        favorite.destroy
        is_favorited = false
        Rails.logger.info "Removed favorite"
      else
        favorite.save!
        is_favorited = true
        Rails.logger.info "Added favorite"
      end
      
      Rails.logger.info "Favorite operation successful. Is favorited: #{is_favorited}"
      
      render json: { 
        status: 'ok',
        is_favorited: is_favorited 
      }
    rescue => e
      Rails.logger.error "Error in toggle_favorite: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: { 
        status: 'error',
        error: e.message 
      }, status: :internal_server_error
    end
  end
  
  def mentionable_users
    query = params[:query]&.downcase || ''
    
    # Get all channel members
    users = @channel.users
    
    if query.present?
      # Filter users by name or email
      users = users.select do |user|
        user_name = user.name.downcase
        user_email = user.email.downcase
        user_name.include?(query) || user_email.include?(query)
      end
    else
      users = users.to_a
    end
    
    users_data = users.first(10).map do |user|
      {
        id: user.id,
        name: user.name,
        email: user.email,
        avatar_url: user.avatar_url || ActionController::Base.helpers.asset_path('default-avatar.png')
      }
    end
    
    render json: { users: users_data }
  end

  private

  def set_channel
    @channel = Channel.find(params[:id])
    
    # Check if user has access to this channel
    unless @channel.users.include?(current_user)
      redirect_to channels_path, alert: "채널에 접근할 수 없습니다."
      return
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to channels_path, alert: "채널을 찾을 수 없습니다."
  end

  def channel_params
    params.require(:channel).permit(:name, :description, :is_private)
  end
end
