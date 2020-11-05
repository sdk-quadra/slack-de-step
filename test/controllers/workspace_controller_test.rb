# frozen_string_literal: true

require "test_helper"

class WorkspaceControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get workspace_index_url
    assert_response :success
  end
end
