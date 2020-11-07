# frozen_string_literal: true

class HomesController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server
  skip_before_action :check_logined

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

    when "member_joined_channel"
      companion ||= Companion.find_by(slack_user_id: user)
      channel = Channel.find_by(slack_channel_id: channel)

      ### 既存userの場合
      if companion
        Participation.new(companion_id: companion.id, channel_id: channel.id).save!
      else
        ### 新規user登録の場合。user登録+channel登録。team_joinイベントはchannel参加のjson取れないのでmember_joined_channelで行う
        app_id = Workspace.find_by(slack_ws_id: team).app.id
        companion = Companion.new(app_id: app_id, slack_user_id: user).save!

        ### default設定のchannelの1つ目を登録する。2つ目以降のchannelはuser登録ありの上記で登録する
        channel = Channel.find_by(slack_channel_id: channel)
        Participation.new(companion_id: companion.id, channel_id: channel.id).save!
      end
    when "member_left_channel"
      companion = Companion.find_by(slack_user_id: user)
      channel = Channel.find_by(slack_channel_id: channel)
      participation = Participation.find_by(companion_id: companion.id, channel_id: channel.id)
      participation.destroy
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
end
