# frozen_string_literal: true

FactoryBot.define do
  factory :app do
    sequence(:workspace_id) { 1 }
    sequence(:oauth_bot_token) { ENV["OAUTH_BOT_TOKEN"] }
    sequence(:bot_user_id) { "U01G0CZR6HX" }
    sequence(:api_app_id) { "A01BNHJJ21X" }
  end
end
