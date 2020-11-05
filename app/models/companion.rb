class Companion < ApplicationRecord
  has_many :participations
  has_many :channels, through: :participations
end
