# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    sequence(:channel_id) { 1 }
    sequence(:message) { "メッセージ登録テスト" }
  end
end
