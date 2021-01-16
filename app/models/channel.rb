# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :app
  has_many :participations, dependent: :destroy
  has_many :companions, through: :participations
  has_many :messages, dependent: :destroy

  validates :name, presence: true
  validates :slack_channel_id, presence: true

  extend CurlBuilder

  def self.create_channels(auth, app)
    oauth_bot_token = auth["access_token"]
    conversations_list = conversations_list(oauth_bot_token)
    conversations = JSON.parse(conversations_list[0])["channels"]

    conversations.each do |conversation|
      Channel.find_or_create_by!(app_id: app.id, slack_channel_id: conversation["id"]) do |channel|
        channel.app_id = app.id
        channel.slack_channel_id = conversation["id"]
        channel.name = conversation["name"]
      end
      # botをpublic channelに参加させる
      bot_join_to_channel(oauth_bot_token, conversation)
    end
  end

  private
    def self.conversations_list(oauth_bot_token)
      conversations_list = curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_LIST, headers: { "Authorization": "Bearer " + oauth_bot_token })
      conversations_list
    end

    def self.bot_join_to_channel(bot_token, channel)
      curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_JOIN, headers: { "Authorization": "Bearer " + bot_token },
                params: { "channel": channel["id"] })
    end
end
