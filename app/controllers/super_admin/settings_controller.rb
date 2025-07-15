class SuperAdmin::SettingsController < SuperAdmin::BaseController
  def index
    # System settings would be loaded from a configuration file or database
    @settings = {
      max_workspaces_per_user: 10,
      max_storage_per_workspace_mb: 10240, # 10GB
      allow_new_signups: true,
      require_email_verification: true,
      default_workspace_member_limit: 100,
      maintenance_mode: false
    }
  end
end