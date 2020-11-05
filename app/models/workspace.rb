# frozen_string_literal: true

class Workspace < ApplicationRecord
  belongs_to :user
  has_one :app
end
