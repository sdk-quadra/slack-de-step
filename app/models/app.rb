# frozen_string_literal: true

class App < ApplicationRecord
  belongs_to :workspace
  has_many :channels
  has_many :companions
end
