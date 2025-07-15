require "test_helper"

class KanbanControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get kanban_index_url
    assert_response :success
  end
end
