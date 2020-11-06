# frozen_string_literal: true

class CurlBuilder
  def build(base_url:, method: "GET", params: {}, headers: {}, body_filename: nil, verbose: true, silent: true, options: "")
    url = base_url
    url += "?" + URI.encode_www_form(params) unless params.empty?
    cmd = "curl '#{url}'"
    cmd += " -d '@#{body_filename}'" if body_filename
    cmd += " " + headers.map { |k, v| "-H '#{k}: #{v}'" }.join(" ") + " " unless headers.empty?
    # cmd += " -v " if verbose
    cmd += " -s " if silent
    # cmd += options
    cmd
  end

  def exec(*args, **kwargs)
    cmd = build(*args, **kwargs)
    o, e, s = Open3.capture3(cmd)
  end
end

class ChannelsController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server

  def index; end

  def new; end

  def show
    @channel = params[:id]
    @channels = Channel.where(app_id: session[:app_id])

    curl = CurlBuilder.new
    bot_token = ENV["OAUTH_BOT_TOKEN"]
    bot_user_id = ENV["BOT_USER_ID"]

    user_info = curl.exec(base_url: "https://slack.com/api/users.info?user=#{bot_user_id}", headers: { "Authorization": "Bearer " + bot_token })
    @user_info_realname = JSON.parse(user_info[0])["user"]["real_name"]
    @user_info_profile_image = JSON.parse(user_info[0])["user"]["profile"]["image_192"]

    @messages_sorted = Message.where(channel_id: params[:id]).sort_by do |message|
      [message.push_timing.in_x_days, message.push_timing.time.to_i]
    end
  end

  def server
    ### リクエストURL確認用
    p "------paramsccc----"
    p params
    p "------paramsccc----"

    if params[:event].present? && params[:event][:type] == "channel_created"
      channel_id = params[:event][:channel][:id]
      channel_name = params[:event][:channel][:name]

      app_id = Workspace.find_by(slack_ws_id: params[:team_id]).app.id
      Channel.new(app_id: app_id, slack_channel_id: channel_id, name: channel_name).save!

      render status: 200, json: {status: 200}

    elsif params[:event].present? && params[:event][:type] == "channel_deleted"
      channel_id = params[:event][:channel]
      Channel.find_by(slack_channel_id: channel_id).destroy

      render status: 200, json: {status: 200}

    elsif params[:event].present? && params[:event][:type] == "member_joined_channel"

      ### 既存userのchannel登録
      companion = Companion.find_by(slack_user_id: params[:event][:user]) if Companion.find_by(slack_user_id: params[:event][:user]).present?
      channel = Channel.find_by(slack_channel_id: params[:event][:channel]) if Channel.find_by(slack_channel_id: params[:event][:channel]).present?

      if companion && channel
        Participation.find_or_create_by!(companion_id: companion.id, channel_id: channel.id) do |participation|
          participation.companion_id = companion.id
          participation.channel_id = channel.id
        end

      else
        ### 新規user登録の場合。user登録+channel登録。team_joinイベントはchannel参加のjson取れないのでmember_joinで行う
        app_id = Workspace.find_by(slack_ws_id: params[:team_id]).app.id if Workspace.find_by(slack_ws_id: params[:team_id]).present?
        slack_user_id = params[:event][:user] if params[:event][:user].present?

        companion = Companion.find_or_create_by!(app_id: app_id, slack_user_id: slack_user_id) do |companion|
          companion.app_id = app_id
          companion.slack_user_id = slack_user_id
        end

        ### default設定のchannelの1つ目を登録する。2つ目以降のchannelはuser登録ありの上記で登録する
        channel = Channel.find_by(slack_channel_id: params[:event][:channel]) if Channel.find_by(slack_channel_id: params[:event][:channel]).present?

        Participation.find_or_create_by!(companion_id: companion.id, channel_id: channel.id) do |participation|
          participation.companion_id = companion.id
          participation.channel_id = channel.id
        end
      end

      render status: 200, json: { status: 200 }

    elsif params[:event].present? && params[:event][:type] == "member_left_channel"
      companion = Companion.find_by(slack_user_id: params[:event][:user])
      channel = Channel.find_by(slack_channel_id: params[:event][:channel])

      participation = Participation.find_by(companion_id: companion.id, channel_id: channel.id)
      participation.destroy

      render status: 200, json: {status: 200}
    else

      render body: params[:challenge]
    end
  end
end
