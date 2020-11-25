# frozen_string_literal: true

class Events::MemberJoinedChannel
  include MessageBuilder

  def execute(bot_token, params)
    # #
    # channelにuserが参加した時の処理
    # #

    user = params[:event][:user]
    team = params[:team_id]
    channel = params[:event][:channel]

    return if params[:authorizations][0][:is_bot] == "true"

    # 新規参加userの場合
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

    messages = channel_to_join.messages

    if messages
      messages.each do |message|
        push_timing = message.push_timing
        x_days_time = {}
        x_days_time.store(:in_x_days, push_timing.in_x_days)
        x_days_time.store(:time, push_timing.time)

        participation_datetime = companion.participations.find_by(channel_id: channel_to_join.id).created_at
        push_datetime = push_datetime(participation_datetime, x_days_time)

        if push_datetime > Time.now
          schedule_message(bot_token, companion, push_datetime, message)
        end
      end
    end
  end

  def member_count(channel)
    member_count = Channel.find_by(slack_channel_id: channel).participations.count
    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end
end
