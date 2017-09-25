require 'test_helper'

class TeamStatsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get team_stats_new_url
    assert_response :success
  end

  test 'should get show' do
    get team_stats_show_url
    assert_response :success
  end

  test 'should get create' do
    get team_stats_create_url
    assert_response :success
  end

  test 'should get get_stats' do
    get team_stats_get_stats_url
    assert_response :success
  end
end
