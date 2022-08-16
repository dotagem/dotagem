require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get telegram" do
    get sessions_telegram_url
    assert_response :success
  end

  test "should get steam" do
    get sessions_steam_url
    assert_response :success
  end

  test "should get destroy" do
    get sessions_destroy_url
    assert_response :success
  end
end
