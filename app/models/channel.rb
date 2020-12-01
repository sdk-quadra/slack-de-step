# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :app
  has_many :participations, dependent: :destroy
  has_many :companions, through: :participations
  has_many :messages, dependent: :destroy

  validates :name, presence: true
  validates :slack_channel_id, presence: true
end
