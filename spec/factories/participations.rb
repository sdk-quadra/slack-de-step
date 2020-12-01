# frozen_string_literal: true

FactoryBot.define do
  factory :participation do
    sequence(:channel_id) { 1 }
    sequence(:companion_id) { 1 }
  end
end
