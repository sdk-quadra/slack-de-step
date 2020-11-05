# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :slack, ENV["SLACK_CLIENT_ID"], ENV["SLACK_CLIENT_SECRET"], name: :sign_in_with_slack
  provider :slack, ENV["SLACK_CLIENT_ID"], ENV["SLACK_CLIENT_SECRET"], scope: "channels:read,team:read,users:read,users:read.email,reactions:read,identify,bot"
end
