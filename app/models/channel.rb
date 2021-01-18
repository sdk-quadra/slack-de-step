# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :app
  has_many :participations, dependent: :destroy
  has_many :companions, through: :participations
  has_many :messages, dependent: :destroy

  validates :name, presence: true
  validates :slack_channel_id, presence: true

  extend CurlBuilder
  extend CryptBuilder

  class << self
    def create_channels(auth, app)
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

    def create_channel(bot_token, team, channel)
      name = channel_name(bot_token, channel[:id])
      app_id = Workspace.find_by(slack_ws_id: team).app.id

      Channel.find_or_create_by!(app_id: app_id, slack_channel_id: channel[:id]) do |c|
        c.app_id = app_id
        c.name = name
        c.slack_channel_id = channel[:id]
      end
    end

    def sort_channels(workspace)
      channels = App.find_by(workspace_id: workspace.id).channels.sort do |x, y|
        [-x[:member_count], x[:name]] <=> [-y[:member_count], y[:name]]
      end

      general_index = channels.index { |i| i.name == "general" }
      general_channel = channels[general_index]

      channels.reject! { |c| c.name == "general" }
      channels.unshift(general_channel)
    end

    def channel_members(bot_token, channel)
      conversations_members = conversations_members(bot_token, channel)
      JSON.parse(conversations_members[0])["members"]
    end

    def bot_join_to_new_channel(bot_token, channel)
      curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_JOIN,
                headers: { "Authorization": "Bearer " + bot_token }, params: { "channel": channel[:id] })
    end

    def event_case(params, event_type)
      bot_token = decrypt_token(Workspace.find_by(slack_ws_id: params[:team_id]).app.oauth_bot_token)

      case event_type
      when "channel_created"
        Events::ChannelCreated.new.execute(bot_token, params)

      when "channel_deleted"
        Events::ChannelDeleted.new.execute(bot_token, params)

      when "channel_rename"
        Events::ChannelRename.new.execute(params)

      when "member_joined_channel"
        Events::MemberJoinedChannel.new.execute(bot_token, params)

      when "member_left_channel"
        Events::MemberLeftChannel.new.execute(bot_token, params)

      when "message"
        Events::Message.new.execute(params)

      when "app_home_opened"
        Events::AppHomeOpened.new.execute(params)
      end
    end

    private
      def channel_name(bot_token, channel)
        conversations_info = conversations_info(bot_token, channel)
        JSON.parse(conversations_info[0])["channel"]["name"]
      end

      def conversations_members(bot_token, channel)
        curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_MEMBERS,
                  headers: { "Authorization": "Bearer " + bot_token }, params: { "channel": channel[:id] })
      end

      def conversations_info(bot_token, channel)
        curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_INFO,
                  params: { "token": bot_token, "channel": channel })
      end

      def conversations_list(oauth_bot_token)
        curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_LIST,
                  headers: { "Authorization": "Bearer " + oauth_bot_token })
      end

      def bot_join_to_channel(bot_token, channel)
        curl_exec(base_url: SlackApiBaseurl::CONVERSATIONS_JOIN,
                  headers: { "Authorization": "Bearer " + bot_token }, params: { "channel": channel["id"] })
      end
  end
end
