# frozen_string_literal: true

class IndividualMessage < ApplicationRecord
  belongs_to :message
  belongs_to :companion

  validates :scheduled_message_id, presence: true
  validates :scheduled_datetime, presence: true

  class << self
    def save_individual_messages(member, message, scheduled_message)
      companion_id = Companion.find_by(slack_user_id: member).id
      message_id = message.id
      scheduled_message_id = JSON.parse(scheduled_message[0])["scheduled_message_id"]
      scheduled_timestamp = JSON.parse(scheduled_message[0])["post_at"]

      individual_message = IndividualMessage.find_or_initialize_by(message_id: message_id, companion_id: companion_id)
      individual_message.update_attributes(
        scheduled_message_id: scheduled_message_id,
        scheduled_datetime: Time.at(scheduled_timestamp)
      )
    end

    def destroy_individual_message(individual_message)
      individual_message.destroy unless individual_message.nil?
    end
  end
end
