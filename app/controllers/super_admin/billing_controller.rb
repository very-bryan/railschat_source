class SuperAdmin::BillingController < SuperAdmin::BaseController
  def index
    @total_revenue = 0 # Placeholder for actual billing data
    @active_subscriptions = 0
    @trial_workspaces = Workspace.count # All workspaces are on trial for now
    
    # Mock billing data for demonstration
    @recent_transactions = []
    @subscription_breakdown = {
      '무료 플랜' => Workspace.count,
      '기본 플랜' => 0,
      '프로 플랜' => 0,
      '엔터프라이즈' => 0
    }
  end
end