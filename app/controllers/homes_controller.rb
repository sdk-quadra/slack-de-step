# frozen_string_literal: true

class HomesController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server
  skip_before_action :check_logined
  before_action :already_logined

  include CryptBuilder

  def index
  end

  def server
    if params[:challenge]
      render body: params[:challenge]
    else
      event(params)
    end
  end

  def event(params)
    event = params[:event][:type]
    bot_token = decrypt_token(Workspace.find_by(slack_ws_id: params[:team_id]).app.oauth_bot_token)

    case event
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
    render status: 200, json: { status: 200 }
  end

  private
    def already_logined
      if session[:user_id]
        redirect_to workspaces_path
      end
    end
end
