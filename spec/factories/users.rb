# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { "slackdestep" }
    sequence(:email) { "slackdestep@gmail.com" }
  end
end
