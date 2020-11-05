# frozen_string_literal: true

class Channel < ApplicationRecord
  has_many :participations
  has_many :companions, through: :participations
  has_many :messages
end
