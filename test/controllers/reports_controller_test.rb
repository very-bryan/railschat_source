require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_index_url
    assert_response :success
  end

  test "should get analytics" do
    get reports_analytics_url
    assert_response :success
  end
end
