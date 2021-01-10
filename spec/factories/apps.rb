# frozen_string_literal: true

FactoryBot.define do
  factory :app do
    sequence(:workspace_id) { 1 }
    sequence(:oauth_bot_token) { ENV["OAUTH_BOT_TOKEN"] }
    sequence(:bot_user_id) { ENV["BOT_USER_ID"] }
    sequence(:salt) { ENV["SALTED_KEY"] }
  end
end
