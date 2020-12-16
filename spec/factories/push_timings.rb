# frozen_string_literal: true

FactoryBot.define do
  factory :push_timing do
    sequence(:message_id) { 1 }
    sequence(:time) { Time.now.since(5400) }
    sequence(:in_x_days) { 1 }
  end
end
