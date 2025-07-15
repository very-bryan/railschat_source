require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get notifications_index_url
    assert_response :success
  end

  test "should get show" do
    get notifications_show_url
    assert_response :success
  end

  test "should get update" do
    get notifications_update_url
    assert_response :success
  end

  test "should get destroy" do
    get notifications_destroy_url
    assert_response :success
  end

  test "should get mark_all_read" do
    get notifications_mark_all_read_url
    assert_response :success
  end
end
