require "test_helper"

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get channels_index_url
    assert_response :success
  end

  test "should get show" do
    get channels_show_url
    assert_response :success
  end

  test "should get create" do
    get channels_create_url
    assert_response :success
  end
end
