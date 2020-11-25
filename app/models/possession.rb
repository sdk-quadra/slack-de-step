# frozen_string_literal: true

class Possession < ApplicationRecord
  belongs_to :user
  belongs_to :workspace
end
