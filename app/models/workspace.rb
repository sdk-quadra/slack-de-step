# frozen_string_literal: true

class Workspace < ApplicationRecord
  has_many :possessions, dependent: :destroy
  has_many :users, through: :possessions
  has_one :app, dependent: :destroy

  validates :slack_ws_id, presence: true
  validates :name, presence: true
  validates :icon_url, presence: true

  def self.create_workspace(users_identity)
    slack_ws_id = users_identity["team"]["id"]
    name = users_identity["team"]["name"]
    icon_url = users_identity["team"]["image_132"]
    workspace = Workspace.find_or_initialize_by(slack_ws_id: slack_ws_id) do |w|
      w.slack_ws_id = slack_ws_id
      w.name = name
      w.icon_url = icon_url
    end

    workspace
  end
end
