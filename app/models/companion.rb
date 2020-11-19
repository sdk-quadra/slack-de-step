# frozen_string_literal: true

class Companion < ApplicationRecord
  belongs_to :app
  has_many :participations, dependent: :destroy
  has_many :individual_messages, dependent: :destroy
  has_many :channels, through: :participations
end
