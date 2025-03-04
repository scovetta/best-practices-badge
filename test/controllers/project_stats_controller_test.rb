# frozen_string_literal: true

# Copyright 2015-2017, the Linux Foundation, IDA, and the
# CII Best Practices badge contributors
# SPDX-License-Identifier: MIT

require 'test_helper'

# rubocop:disable Metrics/ClassLength
class ProjectStatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_stat = project_stats(:one)
  end

  test 'should get index' do
    get '/en/project_stats'
    assert_response :success
    assert @response.body.include?('All projects')
    assert @response.body.include?(
      '<h2>Projects with badge entry activity in last 30 days</h2>'
    )
    # This isn't normally shown:
    assert_not @response.body.include?('Percentage of projects earning badges')
  end

  test 'should get index as admin' do
    log_in_as(users(:admin_user))
    get '/en/project_stats'
    assert_response :success
    assert @response.body.include?('All projects')
    assert @response.body.include?(
      '<h2>Projects with badge entry activity in last 30 days</h2>'
    )
    assert @response.body.include?('As an admin, you may also see')
  end

  test 'should get uncommon stats on request' do
    get '/en/project_stats?type=uncommon'
    assert @response.body.include?('Daily badge entry activity')
    assert @response.body.include?('Percentage of projects earning badges')
  end

  # rubocop:disable Metrics/BlockLength
  test 'should get index, CSV format' do
    get '/en/project_stats.csv'
    assert_response :success
    contents = CSV.parse(@response.body, headers: true)
    assert_equal 'id', contents.headers[0]

    expected_headers = %w[
      id percent_ge_0 percent_ge_25 percent_ge_50
      percent_ge_75 percent_ge_90 percent_ge_100
      created_since_yesterday updated_since_yesterday created_at
      updated_at reminders_sent reactivated_after_reminder
      active_projects active_in_progress projects_edited
      active_edited_projects active_edited_in_progress
      percent_1_ge_25 percent_1_ge_50 percent_1_ge_75
      percent_1_ge_90 percent_1_ge_100 percent_2_ge_25
      percent_2_ge_50 percent_2_ge_75 percent_2_ge_90
      percent_2_ge_100 users github_users local_users
      users_created_since_yesterday users_updated_since_yesterday
      users_with_projects users_without_projects
      users_with_multiple_projects users_with_passing_projects
      users_with_silver_projects users_with_gold_projects
      additional_rights_entries projects_with_additional_rights
      users_with_additional_rights
    ]
    assert_equal expected_headers, contents.headers

    assert_equal 2, contents.size
    assert_equal '13', contents[0]['percent_ge_50']
    assert_equal '20', contents[0]['percent_ge_0']
    assert_equal '19', contents[1]['percent_ge_0']
  end
  # rubocop:enable Metrics/BlockLength

  test 'should NOT be able to get new' do
    assert_raises AbstractController::ActionNotFound do
      get '/en/project_stats/new'
    end
  end

  test 'should NOT be able create project_stat' do
    log_in_as(users(:admin_user))
    assert_raises AbstractController::ActionNotFound do
      post '/en/project_stats', params: {
        project_stat: {
          percent_ge_0: @project_stat.percent_ge_0,
          percent_ge_25: @project_stat.percent_ge_25,
          percent_ge_50: @project_stat.percent_ge_50,
          percent_ge_75: @project_stat.percent_ge_75,
          percent_ge_90: @project_stat.percent_ge_90,
          percent_ge_100: @project_stat.percent_ge_100,
          created_since_yesterday: @project_stat.created_since_yesterday,
          updated_since_yesterday: @project_stat.updated_since_yesterday
        }
      }
    end
  end

  test 'should show project_stat' do
    get "/de/project_stats/#{@project_stat.id}"
    assert_response :success
  end

  test 'should NOT get edit' do
    assert_raises AbstractController::ActionNotFound do
      get "/de/project_stats/#{@project_stat.id}/edit"
    end
  end

  test 'should NOT update project_stat' do
    log_in_as(users(:admin_user))
    assert_raises AbstractController::ActionNotFound do
      patch "/en/project_stats/#{@project_stat.id}", params: {
        id: @project_stat,
        project_stat: {
          percent_ge_0: @project_stat.percent_ge_0,
          percent_ge_25: @project_stat.percent_ge_25,
          percent_ge_50: @project_stat.percent_ge_50,
          percent_ge_75: @project_stat.percent_ge_75,
          percent_ge_90: @project_stat.percent_ge_90,
          percent_ge_100: @project_stat.percent_ge_100,
          created_since_yesterday: @project_stat.created_since_yesterday,
          updated_since_yesterday: @project_stat.updated_since_yesterday
        }
      }
    end
  end

  test 'should NOT destroy project_stat' do
    log_in_as(users(:admin_user))
    assert_raises AbstractController::ActionNotFound do
      delete "/en/project_stats/#{@project_stat.id}"
    end
  end
end
# rubocop:enable Metrics/ClassLength
