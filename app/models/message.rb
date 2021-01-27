# frozen_string_literal: true

class Message < ApplicationRecord
  MAX_MESSAGE_COUNT = 50

  has_one :push_timing, dependent: :destroy
  has_many :individual_messages, dependent: :destroy
  has_many :transceptions, dependent: :destroy
  belongs_to :channel
  accepts_nested_attributes_for :push_timing
  mount_uploader :image, ImageUploader

  extend Builders::MessageBuilder

  validates :message, presence: true
  with_options if: -> { message.present? } do
    validate :limit_message
  end

  def limit_message
    if channel.present? && channel.messages.count >= MAX_MESSAGE_COUNT
      errors.add(:max_message, "は1つのchannelで#{MAX_MESSAGE_COUNT}までです")
    end
  end

  class << self
    def sort_messages(params)
      messages = Message.where(channel_id: params[:id]).sort_by do |message|
        [message.push_timing.in_x_days, message.push_timing.time.to_i]
      end
      messages
    end

    def reserve_messages(bot_token, companion, channel_to_join, messages)
      messages.each do |message|
        push_timing = message.push_timing

        participation_datetime = companion.participations.find_by(channel_id: channel_to_join.id).created_at
        push_datetime = push_datetime(participation_datetime, push_timing.in_x_days, push_timing.time)

        if push_datetime > Time.now
          schedule_message(bot_token, companion, push_datetime, message)
        end
      end
    end

    def cancel_reserved_messages(bot_token, user, channel)
      messages = Channel.find_by(slack_channel_id: channel).messages
      companion_id = Companion.find_by(slack_user_id: user).id

      messages.each.with_index(1) do |m, index|
        individual_message = m.individual_messages.find_by(companion_id: companion_id)
        delete_scheduled_message(bot_token, index, individual_message)

        IndividualMessage.destroy_individual_message(individual_message)
      end
    end
  end
end
