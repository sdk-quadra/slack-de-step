# frozen_string_literal: true

class HomesController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server
  skip_before_action :check_logined

  def index
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
    elsif params[:event].present? && params[:event][:type] == "message" && App.exists?(bot_user_id: params[:event][:user])

      transception = Transception.new
      transception.conversation_id = params[:event][:channel]
      transception.save!

      render status: 200, json: {status: 200}

    elsif params[:event].present? && params[:event][:type] == "app_home_opened" && Transception.exists?(conversation_id: params[:event][:channel])

      transception = Transception.where(conversation_id: params[:event][:channel])
      transception.update(is_read: true)

      render status: 200, json: {status: 200}
    else

      render body: params[:challenge]
    end
  end
end
