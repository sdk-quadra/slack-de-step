# frozen_string_literal: true

class HomesController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server
  skip_before_action :check_logined
  before_action :already_logined
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
    api_app = params[:api_app_id]

    case event
    when "channel_created"
      # botをchannel登録する # channel_created => member_joined_channelの順に動くのは確実(botを埋めてからしかlogに出ないので)
      bot_token = App.find_by(api_app_id: api_app).oauth_bot_token
      join_to_channel(bot_token, channel)

      create_channel(api_app, channel)

      members = conversations_members(bot_token, channel)
      participate_channel(members, channel)

    when "channel_deleted"
      bot_token = App.find_by(api_app_id: api_app).oauth_bot_token
      message_ids = Channel.find_by(slack_channel_id: channel).messages.map(&:id)
      delete_scheduled_messages(bot_token, message_ids)

      Channel.find_by(slack_channel_id: channel).destroy

    when "channel_rename"
      Channel.find_by(slack_channel_id: channel[:id]).update(name: channel[:name])

    when "member_joined_channel"

      # 新規userの場合
      companion = Companion.find_or_create_by!(slack_user_id: user) do |c|
        app_id = Workspace.find_by(slack_ws_id: team).app.id
        c.app_id = app_id
        c.slack_user_id = user
      end

      channel_to_join = Channel.find_by(slack_channel_id: channel)
      unless App.exists?(bot_user_id: user)
        Participation.find_or_create_by!(companion_id: companion.id, channel_id: channel_to_join.id) do |p|
          p.companion_id = companion.id
          p.channel_id = channel_to_join.id
        end
      end
      member_count(channel)

    when "member_left_channel"
      companion = Companion.find_by(slack_user_id: user)
      channel_to_leave = Channel.find_by(slack_channel_id: channel)
      participation = Participation.find_by(companion_id: companion.id, channel_id: channel_to_leave.id)
      participation.destroy unless participation.nil?
      member_count(channel)

    when "channel_left"
      bot_user_id = App.find_by(api_app_id: api_app).bot_user_id
      companion = Companion.find_by(slack_user_id: bot_user_id)
      channel_to_leave = Channel.find_by(slack_channel_id: channel)
      participation = Participation.find_by(companion_id: companion.id, channel_id: channel_to_leave.id)
      participation.destroy unless participation.nil?
      member_count(channel)

    when "message"
      return if params[:event][:subtype].present?

      message_id = params[:event][:blocks][0][:block_id]
      # messageで受けるイベントは複数ある為,bot_user_idで選別
      from_bot = App.exists?(bot_user_id: user)
      is_test_message = message_id == "test_message" ? true : false

      if from_bot && !is_test_message
        Transception.new(conversation_id: channel, message_id: message_id.to_i).save!
      end

    when "app_home_opened"
      transception = Transception.where(conversation_id: channel)
      transception.update(is_read: true)
    end
    render status: 200, json: { status: 200 }
  end

  def member_count(channel)
    member_count = Channel.find_by(slack_channel_id: channel).participations.count
    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end

  def channel_name(api_app, channel)
    bot_token = App.find_by(api_app_id: api_app).oauth_bot_token
    conversation_info = curl_exec(base_url: "https://slack.com/api/conversations.info",
                                  params: { "token": bot_token, "channel": channel })
    channel_name = JSON.parse(conversation_info[0])["channel"]["name"]
    channel_name
  end

  def create_channel(api_app, channel)
    api_app_id = App.find_by(api_app_id: api_app).id
    name = channel_name(api_app, channel[:id])
    Channel.create(app_id: api_app_id, name: name, slack_channel_id: channel[:id], member_count: 0)
  end

  def join_to_channel(bot_token, channel)
    curl_exec(base_url: "https://slack.com/api/conversations.join", headers: { "Authorization": "Bearer " + bot_token },
              params: { "channel": channel[:id] })
  end

  def conversations_members(bot_token, channel)
    conversations_members = curl_exec(base_url: "https://slack.com/api/conversations.members", headers: { "Authorization": "Bearer " + bot_token },
              params: { "channel": channel[:id] })
    members = JSON.parse(conversations_members[0])["members"]
    members
  end

  def participate_channel(members, channel)
    members.each do |member|
      companion_id = Companion.find_by(slack_user_id: member).id
      channel_id = Channel.find_by(slack_channel_id: channel[:id]).id
      Participation.create(companion_id: companion_id, channel_id: channel_id) unless App.exists?(bot_user_id: member)
    end
  end

  private

    def already_logined
      if session[:user_id]
        redirect_to workspaces_path
      end
    end

    def delete_scheduled_messages(bot_token, message_ids)
      individual_messages = IndividualMessage.where(message_id: message_ids)

      individual_messages.each do |individual_message|
        scheduled_datetime = individual_message.scheduled_datetime
        if scheduled_datetime > Time.now
          curl_exec(base_url: "https://slack.com/api/chat.deleteScheduledMessage",
                    params: { "token": bot_token, "channel": individual_message.companion.slack_user_id, "scheduled_message_id": individual_message.scheduled_message_id })
        end
      end
    end
end
