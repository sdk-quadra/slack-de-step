# frozen_string_literal: true

FactoryBot.define do
  factory :possession do
    sequence(:user_id) { 1 }
    sequence(:workspace_id) { 1 }
  end
end
