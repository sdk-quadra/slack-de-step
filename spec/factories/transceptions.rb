# frozen_string_literal: true

FactoryBot.define do
  factory :transception do
    sequence(:message_id) { 1 }
    sequence(:conversation_id) { "test_conversation_id" }
  end
end
