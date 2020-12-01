# frozen_string_literal: true

class PushTiming < ApplicationRecord
  belongs_to :message

  validates :time, presence: true
  validates :in_x_days, presence: true
end
