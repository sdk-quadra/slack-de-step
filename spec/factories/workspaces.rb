# frozen_string_literal: true

FactoryBot.define do
  factory :workspace do
    sequence(:slack_ws_id) { "T01FL373G1Z" }
    sequence(:name) { "slack-de-step" }
    sequence(:icon_url) { "https://a.slack-edge.com/80588/img/avatars-teams/ava_0023-132.png" }
  end
end
