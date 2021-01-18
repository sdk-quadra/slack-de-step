# frozen_string_literal: true

class Transception < ApplicationRecord
  belongs_to :message

  validates :conversation_id, presence: true

  class << self
    def save_transception(user, channel, message_id)
      # messageという値で受けるイベントは複数ある為、bot_user_idで選別
      from_bot = App.exists?(bot_user_id: user)

      is_test_message = message_id == "test_message" ? true : false

      if from_bot && !is_test_message
        Transception.new(conversation_id: channel, message_id: message_id.to_i).save!
      end
    end
  end
end
