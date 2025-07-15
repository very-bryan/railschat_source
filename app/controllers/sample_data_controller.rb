class SampleDataController < ApplicationController
  before_action :authenticate_user!
  
  def destroy
    workspace = current_user.current_workspace
    
    # Delete sample notes
    Note.where(workspace: workspace, is_sample: true).destroy_all
    
    # Delete sample messages
    Message.joins(:channel).where(channels: { workspace: workspace }, is_sample: true).destroy_all
    
    # Delete sample users (only those marked as sample and belonging to this workspace)
    sample_users = User.where(provider: 'sample').joins(:workspace_members)
                      .where(workspace_members: { workspace: workspace })
    
    sample_users.each do |user|
      # Only delete if user belongs only to this workspace
      if user.workspaces.count == 1
        user.destroy
      else
        # Remove from this workspace only
        user.workspace_members.where(workspace: workspace).destroy_all
      end
    end
    
    redirect_to root_path, notice: '샘플 데이터가 삭제되었습니다.'
  end
end