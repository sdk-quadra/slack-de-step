# frozen_string_literal: true

require "application_system_test_case"

class BorrwedTest < ApplicationSystemTestCase
  test "show listing borrowed books" do
    visit "/"
    assert_equal "SlackDeStep", title
  end
end
