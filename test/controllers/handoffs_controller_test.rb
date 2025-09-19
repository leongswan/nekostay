require "test_helper"

class HandoffsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get handoffs_index_url
    assert_response :success
  end

  test "should get complete" do
    get handoffs_complete_url
    assert_response :success
  end
end
