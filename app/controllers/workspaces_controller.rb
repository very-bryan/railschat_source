class WorkspacesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :require_pending_user, only: [:new, :create]
  before_action :require_admin!, only: [:destroy]

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(workspace_params)
    
    if @workspace.save
      # Get user from session
      user = User.find(session[:pending_user_id])
      
      # Create admin membership
      @workspace.workspace_members.create!(user: user, role: 'admin')
      
      # Set as current workspace
      user.update!(current_workspace: @workspace)
      
      # Sign in user
      sign_in(user)
      
      # Clear session
      session.delete(:pending_user_id)
      
      # Setup workspace with default data
      begin
        WorkspaceSetupService.setup_workspace(@workspace, user)
        Rails.logger.info "Workspace setup completed for #{@workspace.name}"
      rescue => e
        Rails.logger.error "Failed to setup workspace: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
      
      # Create sample data
      begin
        SampleDataGenerator.generate_for_workspace(@workspace, user)
        Rails.logger.info "Sample data created for #{@workspace.name}"
      rescue => e
        Rails.logger.error "Failed to create sample data: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
      
      redirect_to root_path, notice: '워크스페이스가 생성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    @workspace = current_user.current_workspace
    
    # Check if user is admin
    unless current_user.workspace_admin?(@workspace)
      redirect_to root_path, alert: '권한이 없습니다.'
      return
    end
    
    begin
      # Temporarily disable foreign key constraints for SQLite
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF") if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      
      ActiveRecord::Base.transaction do
        Rails.logger.info "=== Starting workspace deletion for: #{@workspace.name} (ID: #{@workspace.id}) ==="
        
        # 1. First, update all users who have this workspace as their current_workspace
        Rails.logger.info "Step 1: Updating current_workspace for users..."
        User.where(current_workspace_id: @workspace.id).update_all(current_workspace_id: nil)
        
        # 2. Delete direct messages if table exists
        if ActiveRecord::Base.connection.table_exists?('direct_messages')
          Rails.logger.info "Step 2: Deleting direct messages..."
          count = ActiveRecord::Base.connection.execute("DELETE FROM direct_messages WHERE workspace_id = #{@workspace.id}")
          Rails.logger.info "  - Deleted direct messages"
        end
        
        # 3. Get all channel IDs for this workspace
        channel_ids = @workspace.channels.pluck(:id)
        Rails.logger.info "Found #{channel_ids.count} channels to delete"
        
        # 4. Get all message IDs for deletion
        message_ids = Message.where(channel_id: channel_ids).pluck(:id) if channel_ids.any?
        Rails.logger.info "Found #{message_ids&.count || 0} messages to delete"
        
        # 5. Delete all message-related data BEFORE deleting messages
        if message_ids&.any?
          Rails.logger.info "Step 3: Deleting message-related data..."
          
          # Delete message mentions
          if ActiveRecord::Base.connection.table_exists?('message_mentions')
            count = MessageMention.where(message_id: message_ids).delete_all
            Rails.logger.info "  - Deleted #{count} message mentions"
          end
          
          # Delete message reactions
          if ActiveRecord::Base.connection.table_exists?('message_reactions')
            count = MessageReaction.where(message_id: message_ids).delete_all
            Rails.logger.info "  - Deleted #{count} message reactions"
          end
          
          # Delete message reads
          if ActiveRecord::Base.connection.table_exists?('message_reads')
            count = MessageRead.where(message_id: message_ids).delete_all
            Rails.logger.info "  - Deleted #{count} message reads"
          end
          
          # Delete saved messages
          if ActiveRecord::Base.connection.table_exists?('saved_messages')
            count = SavedMessage.where(message_id: message_ids).delete_all
            Rails.logger.info "  - Deleted #{count} saved messages"
          end
        end
        
        # 6. Now delete messages themselves (after dependencies are gone)
        if channel_ids.any?
          count = Message.where(channel_id: channel_ids).delete_all
          Rails.logger.info "  - Deleted #{count} messages"
        end
        
        # 7. Delete channel-related data
        if channel_ids.any?
          Rails.logger.info "Step 4: Deleting channel-related data..."
          
          # Delete channel favorites
          if ActiveRecord::Base.connection.table_exists?('channel_favorites')
            count = ChannelFavorite.where(channel_id: channel_ids).delete_all
            Rails.logger.info "  - Deleted #{count} channel favorites"
          end
          
          # Delete channel members
          count = ChannelMember.where(channel_id: channel_ids).delete_all
          Rails.logger.info "  - Deleted #{count} channel members"
        end
        
        # 8. Delete channels
        Rails.logger.info "Step 5: Deleting channels..."
        @workspace.channels.delete_all
        
        # 9. Get all note IDs for this workspace
        note_ids = @workspace.notes.pluck(:id)
        Rails.logger.info "Found #{note_ids.count} notes to delete"
        
        # 10. Delete note-related data
        if note_ids.any?
          Rails.logger.info "Step 6: Deleting note-related data..."
          
          # Delete comments on notes
          if ActiveRecord::Base.connection.table_exists?('comments')
            count = Comment.where(commentable_type: 'Note', commentable_id: note_ids).delete_all
            Rails.logger.info "  - Deleted #{count} comments on notes"
          end
          
          # Delete note assignees
          if ActiveRecord::Base.connection.table_exists?('note_assignees')
            count = NoteAssignee.where(note_id: note_ids).delete_all
            Rails.logger.info "  - Deleted #{count} note assignees"
          end
        end
        
        # 11. Delete messages that reference notes (if any)
        if note_ids.any?
          count = Message.where(note_id: note_ids).delete_all
          Rails.logger.info "  - Deleted #{count} messages referencing notes"
        end
        
        # 12. Delete notifications that might reference workspace content
        Rails.logger.info "Step 7: Cleaning up notifications..."
        if ActiveRecord::Base.connection.table_exists?('notifications')
          # Delete notifications for channels
          if channel_ids.any?
            count = Notification.where(related_type: 'Channel', related_id: channel_ids).delete_all
            Rails.logger.info "  - Deleted #{count} channel notifications"
          end
          # Delete notifications for notes
          if note_ids.any?
            count = Notification.where(related_type: 'Note', related_id: note_ids).delete_all
            Rails.logger.info "  - Deleted #{count} note notifications"
          end
          # Delete notifications for messages
          if message_ids&.any?
            count = Notification.where(related_type: 'Message', related_id: message_ids).delete_all
            Rails.logger.info "  - Deleted #{count} message notifications"
          end
        end
        
        # 13. Delete notes
        Rails.logger.info "Step 8: Deleting notes..."
        @workspace.notes.delete_all
        
        # 14. Delete categories
        Rails.logger.info "Step 9: Deleting categories..."
        @workspace.categories.delete_all
        
        # 15. Delete statuses
        Rails.logger.info "Step 10: Deleting statuses..."
        @workspace.statuses.delete_all
        
        # 16. Delete workspace members
        Rails.logger.info "Step 11: Deleting workspace members..."
        @workspace.workspace_members.delete_all
        
        # 17. Finally, delete the workspace itself
        Rails.logger.info "Step 12: Deleting workspace..."
        @workspace.delete
        
        Rails.logger.info "=== Workspace deletion completed successfully ==="
      end
      
      # If user has other workspaces, switch to the first one
      if current_user.workspaces.reload.any?
        current_user.update!(current_workspace: current_user.workspaces.first)
        redirect_to root_path, notice: '워크스페이스가 삭제되었습니다.'
      else
        # If no other workspaces, sign out and redirect to new workspace page
        sign_out(current_user)
        redirect_to new_user_session_path, notice: '워크스페이스가 삭제되었습니다. 새로운 워크스페이스를 생성하려면 다시 로그인하세요.'
      end
    rescue => e
      Rails.logger.error "워크스페이스 삭제 중 오류: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to root_path, alert: "워크스페이스 삭제 중 오류가 발생했습니다: #{e.message}"
    ensure
      # Re-enable foreign key constraints for SQLite
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON") if ActiveRecord::Base.connection.adapter_name == 'SQLite'
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name, :icon)
  end

  def require_pending_user
    unless session[:pending_user_id].present?
      redirect_to root_path
    end
  end
  
  def require_admin!
    unless current_user.workspace_admin?
      redirect_to root_path, alert: "권한이 없습니다."
    end
  end
end