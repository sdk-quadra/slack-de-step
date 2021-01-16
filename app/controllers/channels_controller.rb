# frozen_string_literal: true

class ChannelsController < ApplicationController
  before_action :set_workspace, only: [:show]
  before_action :set_channel, only: [:show]
  include CurlBuilder
  include CryptBuilder

  def show
    @channels = sorted_channels

    posted_messages = Transception.where(message_id: @channel.messages.map(&:id))
    @pushed_count = posted_messages.count
    @is_read = posted_messages.where(is_read: true).count

    bot_token = decrypt_token(@workspace.app.oauth_bot_token)
    bot_user_id = @workspace.app.bot_user_id

    users_info = users_info(bot_token, bot_user_id)
    @app_info = {}
    @app_info.store(:real_name, JSON.parse(users_info[0])["user"]["real_name"])
    @app_info.store(:icon_url, JSON.parse(users_info[0])["user"]["profile"]["image_192"])

    @messages = sorted_messages
  end

  private
    def set_workspace
      @workspace = Workspace.find(session[:workspace_id])
    end

    def set_channel
      @channel = Channel.find(params[:id])
    end

    def sorted_channels
      channels = App.find_by(workspace_id: @workspace.id).channels.sort do |x, y|
        [-x[:member_count], x[:name]] <=> [-y[:member_count], y[:name]]
      end

      general_index = channels.index { |i| i.name == "general" }
      general_channel = channels[general_index]

      channels.reject! { |c| c.name == "general" }
      sorted_channels = channels.unshift(general_channel)
      sorted_channels
    end

    def sorted_messages
      messages = Message.where(channel_id: params[:id]).sort_by do |message|
        [message.push_timing.in_x_days, message.push_timing.time.to_i]
      end
      messages
    end

    def users_info(bot_token, bot_user_id)
      users_info = curl_exec(base_url: SlackApiBaseurl::USERS_INFO, headers: { "Authorization": "Bearer " + bot_token },
                             params: { "user": bot_user_id })
      users_info
    end
end
