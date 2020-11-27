# frozen_string_literal: true

FactoryBot.define do
  factory :channel do
    sequence(:app_id) { 1 }
    sequence(:name) { "general" }
    sequence(:slack_channel_id) { "C01FYFNM9C1" }
    sequence(:member_count) { 0 }
    sequence(:display) { true }
  end
end
