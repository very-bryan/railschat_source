require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get sessions_destroy_url
    assert_response :success
  end
end
