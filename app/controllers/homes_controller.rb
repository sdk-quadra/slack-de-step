# frozen_string_literal: true

class HomesController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server
  skip_before_action :check_logined
  include CurlBuilder

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
    channel = params[:event][:channel]
    user = params[:event][:user]
    team = params[:team_id]

    case event
    when "channel_created"
      app_id = Workspace.find_by(slack_ws_id: team).app.id
      Channel.new(app_id: app_id, slack_channel_id: channel[:id], name: channel[:name]).save

    when "channel_deleted"
      Channel.find_by(slack_channel_id: channel).destroy

    when "channel_rename"
      Channel.find_by(slack_channel_id: channel[:id]).update(name: channel[:name])

    when "member_joined_channel"
      companion ||= Companion.find_by(slack_user_id: user)
      channel_to_join = Channel.find_by(slack_channel_id: channel)

      ### 新規userの場合もmember_joined_channelが発生する。まずuserを作成
      companion = Companion.find_or_create_by!(slack_user_id: user) do |c|
        app_id = Workspace.find_by(slack_ws_id: team).app.id
        c.app_id = app_id
        c.slack_user_id = user
      end

      Participation.new(companion_id: companion.id, channel_id: channel_to_join.id).save!
      member_count(channel)

    when "member_left_channel"
      companion = Companion.find_by(slack_user_id: user)
      channel_to_leave = Channel.find_by(slack_channel_id: channel)
      participation = Participation.find_by(companion_id: companion.id, channel_id: channel_to_leave.id)
      participation.destroy
      member_count(channel)

    when "message"
      # messageで受けるイベントは複数ある為,bot_user_idで選別
      if App.exists?(bot_user_id: user)
        Transception.new(conversation_id: channel).save!
      end
    when "app_home_opened"
      transception = Transception.where(conversation_id: channel)
      transception.update(is_read: true)
    end
    render status: 200, json: { status: 200 }
  end

  def member_count(channel)
    bot_token = ENV["OAUTH_BOT_TOKEN"]
    conversation_info = curl_exec(base_url: "https://slack.com/api/conversations.info",
                                  params: { "token": bot_token, "channel": channel, "include_num_members": true})
    member_count = JSON.parse(conversation_info[0])["channel"]["num_members"]

    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end
end
