# frozen_string_literal: true

class Workspace < ApplicationRecord
  has_many :possessions, dependent: :destroy
  has_many :users, through: :possessions
  has_one :app, dependent: :destroy

  validates :slack_ws_id, presence: true
  validates :name, presence: true
  validates :icon_url, presence: true
end
