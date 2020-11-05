# frozen_string_literal: true

class App < ApplicationRecord
  belongs_to :workspace
  has_many :channels, dependent: :destroy
  has_many :companions, dependent: :destroy
end
