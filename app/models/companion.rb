# frozen_string_literal: true

class Companion < ApplicationRecord
  belongs_to :app
  has_many :participations, dependent: :destroy
  has_many :individual_messages, dependent: :destroy
  has_many :channels, through: :participations

  validates :slack_user_id, presence: true

  extend CurlBuilder

  def self.create_companions(auth, app)
    oauth_bot_token = auth["access_token"]
    users_list = users_list(oauth_bot_token)
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

  private
    def self.users_list(oauth_bot_token)
      users_list = curl_exec(base_url: SlackApiBaseurl::USERS_LIST, headers: { "Authorization": "Bearer " + oauth_bot_token })
      users_list
    end
end
