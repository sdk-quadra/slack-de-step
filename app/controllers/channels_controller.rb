# frozen_string_literal: true

class ChannelsController < ApplicationController
  before_action :set_workspace, :set_channel, :inaccessible_others_channel, only: [:show]
  include CryptBuilder
  include OwnChecker

  def show
    @channels = Channel.sort_channels(@workspace)

    posted_messages = Transception.where(message_id: @channel.messages.map(&:id))
    @pushed_count = posted_messages.count
    @is_read = posted_messages.where(is_read: true).count

    bot_token = decrypt_token(@workspace.app.oauth_bot_token)
    bot_user_id = @workspace.app.bot_user_id

    users_info = User.users_info(bot_token, bot_user_id)
    @app_info = {}
    @app_info.store(:real_name, JSON.parse(users_info[0])["user"]["real_name"])
    @app_info.store(:icon_url, JSON.parse(users_info[0])["user"]["profile"]["image_192"])

    @messages = Message.sort_messages(params)
  end

  private
    def set_workspace
      @workspace = Workspace.find(session[:workspace_id])
    end

    def set_channel
      @channel = Channel.find(params[:id])
    end

    def inaccessible_others_channel
      check_channel_owner(session[:workspace_id], @channel.id)
    end
end
