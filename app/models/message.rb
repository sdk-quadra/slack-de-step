# frozen_string_literal: true

class Message < ApplicationRecord
  MAX_MESSAGE_COUNT = 50

  has_one :push_timing, dependent: :destroy
  has_many :individual_messages, dependent: :destroy
  has_many :transceptions, dependent: :destroy
  belongs_to :channel
  accepts_nested_attributes_for :push_timing
  mount_uploader :image, ImageUploader

  validates :message, presence: true
  with_options if: -> { message.present? } do
    validate :limit_message
  end

  def limit_message
    if channel.present? && channel.messages.count >= MAX_MESSAGE_COUNT
      errors.add(:max_message, "は1チャネル#{MAX_MESSAGE_COUNT}個までです")
    end
  end

end
