# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :channel
  belongs_to :companion
end
