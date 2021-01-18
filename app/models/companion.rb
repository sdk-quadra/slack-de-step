# frozen_string_literal: true

class Companion < ApplicationRecord
  belongs_to :app
  has_many :participations, dependent: :destroy
  has_many :individual_messages, dependent: :destroy
  has_many :channels, through: :participations

  validates :slack_user_id, presence: true

  extend CurlBuilder

  class << self
    def create_companions(auth, app)
      oauth_bot_token = auth["access_token"]
      users_list = User.users_list(oauth_bot_token)
      users = JSON.parse(users_list[0])["members"]

      users.each do |user|
        unless user["name"] == "slackbot" || user["is_bot"] == true
          Companion.find_or_create_by!(app_id: app.id, slack_user_id: user["id"]) do |companion|
            companion.app_id = app.id
            companion.slack_user_id = user["id"]
          end
        end
      end
    end

    def register_companion(team, user)
      app_id = Workspace.find_by(slack_ws_id: team).app.id
      companion = Companion.find_or_create_by!(app_id: app_id, slack_user_id: user) do |c|
        c.app_id = app_id
        c.slack_user_id = user
      end
      companion
    end
  end
end
