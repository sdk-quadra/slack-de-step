# frozen_string_literal: true

class IndividualMessage < ApplicationRecord
  belongs_to :message
  belongs_to :companion

  validates :scheduled_message_id, presence: true
  validates :scheduled_datetime, presence: true
end
