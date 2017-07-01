require 'test_helper'

class PlayerStatsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get player_stats_new_url
    assert_response :success
  end

  test "should get show" do
    get player_stats_show_url
    assert_response :success
  end

end
