# frozen_string_literal: true

class ChannelsController < ApplicationController
  before_action :set_workspace, only: [:show]
  before_action :set_channel, only: [:show]
  include CurlBuilder

  def show
    channels = App.find_by(workspace_id: @workspace.id).channels.sort do |x, y|
      [-x[:member_count], x[:name]] <=> [-y[:member_count], y[:name]]
    end

    general_index = channels.index { |i| i.name == "general" }
    general_channel = channels[general_index]

    channels.reject! { |c| c.name == "general" }
    @channels = channels.unshift(general_channel)

    post_messages = Transception.where(message_id: @channel.messages.map(&:id))
    @pushed_count = post_messages.count
    @is_read = post_messages.where(is_read: true).count

    bot_token = @workspace.app.oauth_bot_token
    bot_user_id = @workspace.app.bot_user_id

    user_info = curl_exec(base_url: "https://slack.com/api/users.info?user=#{bot_user_id}", headers: { "Authorization": "Bearer " + bot_token })
    @user_info_realname = JSON.parse(user_info[0])["user"]["real_name"]
    @user_info_profile_image = JSON.parse(user_info[0])["user"]["profile"]["image_192"]

    @messages = Message.where(channel_id: params[:id]).sort_by do |message|
      [message.push_timing.in_x_days, message.push_timing.time.to_i]
    end
  end

  private
    def set_workspace
      @workspace = Workspace.find(params[:workspace_id])
    end

    def set_channel
      @channel = Channel.find(params[:id])
    end
end
