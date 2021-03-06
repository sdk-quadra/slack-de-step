# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    sequence(:app_id) { 1 }
    sequence(:name) { "general" }
    sequence(:slack_channel_id) { "C01FYFNM9C1" }
  end
end
