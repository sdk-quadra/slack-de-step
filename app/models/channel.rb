# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :app
  has_many :participations
  has_many :companions, through: :participations
  has_many :messages
end
