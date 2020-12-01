# frozen_string_literal: true

FactoryBot.define do
  factory :companion do
    sequence(:app_id) { 1 }
    sequence(:slack_user_id) { "test_slack_user_id" }
  end
end
