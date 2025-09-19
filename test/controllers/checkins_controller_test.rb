require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get checkins_index_url
    assert_response :success
  end

  test "should get new" do
    get checkins_new_url
    assert_response :success
  end

  test "should get create" do
    get checkins_create_url
    assert_response :success
  end

  test "should get show" do
    get checkins_show_url
    assert_response :success
  end
end
