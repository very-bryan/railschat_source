class SearchController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @query = params[:q]&.strip
    @filter = params[:filter] || 'all'
    @results = {}
    
    if @query.present?
      @results = perform_search(@query, @filter)
    end
    
    @recent_searches = session[:recent_searches] || []
    
    # Store recent search
    if @query.present?
      @recent_searches.unshift(@query)
      @recent_searches = @recent_searches.uniq.first(10)
      session[:recent_searches] = @recent_searches
    end
  end

  private

  def perform_search(query, filter)
    results = {}
    
    case filter
    when 'all'
      results[:notes] = search_notes(query)
      results[:channels] = search_channels(query)
      results[:messages] = search_messages(query)
      results[:users] = search_users(query)
    when 'notes'
      results[:notes] = search_notes(query)
    when 'channels'
      results[:channels] = search_channels(query)
    when 'messages'
      results[:messages] = search_messages(query)
    when 'users'
      results[:users] = search_users(query)
    end
    
    results
  end

  def search_notes(query)
    workspace = current_user.current_workspace
    workspace.notes.includes(:category, :status, :user, :assignees, attachments_attachments: :blob)
                   .where("LOWER(notes.title) LIKE LOWER(?) OR LOWER(notes.body) LIKE LOWER(?)", "%#{query}%", "%#{query}%")
                   .order(updated_at: :desc)
                   .limit(50)
  end

  def search_channels(query)
    workspace = current_user.current_workspace
    workspace.channels.includes(:channel_members)
                      .where("LOWER(channels.name) LIKE LOWER(?) OR LOWER(channels.description) LIKE LOWER(?)", "%#{query}%", "%#{query}%")
                      .order(updated_at: :desc)
                      .limit(20)
  end

  def search_messages(query)
    workspace = current_user.current_workspace
    channel_ids = workspace.channels.pluck(:id)
    Message.includes(:user, :channel)
           .where(channel_id: channel_ids)
           .where("LOWER(messages.content) LIKE LOWER(?)", "%#{query}%")
           .order(created_at: :desc)
           .limit(20)
  end

  def search_users(query)
    workspace = current_user.current_workspace
    workspace.users.where("LOWER(users.first_name) LIKE LOWER(?) OR LOWER(users.last_name) LIKE LOWER(?) OR LOWER(users.email) LIKE LOWER(?)", 
                         "%#{query}%", "%#{query}%", "%#{query}%")
            .where.not(id: current_user.id)
            .order(:first_name, :last_name)
            .limit(20)
  end
end
