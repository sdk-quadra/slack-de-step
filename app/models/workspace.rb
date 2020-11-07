# frozen_string_literal: true

class Workspace < ApplicationRecord
  # belongs_to :user
  has_many :possessions, dependent: :destroy
  has_many :users, through: :possessions
  has_one :app, dependent: :destroy
end
