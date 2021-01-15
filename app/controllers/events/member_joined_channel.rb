# frozen_string_literal: true

class Events::MemberJoinedChannel
  include MessageBuilder
  include ChannelBuilder

  def execute(bot_token, params)
    # #
    # channelにuserが参加した時の処理
    # #

    return if params[:authorizations][0][:is_bot] == "true"

    user = params[:event][:user]
    team = params[:team_id]
    channel = params[:event][:channel]
    channel_to_join = Channel.find_by(slack_channel_id: channel)

    # 新規参加userの場合
    companion = register_companion(team, user)
    participate_channel(user, channel_to_join, companion)

    member_count(channel)

    # channelにセットされているmessageを取得
    messages = channel_to_join.messages
    reserve_messages(bot_token, companion, channel_to_join, messages)
  end

  private
    def register_companion(team, user)
      app_id = Workspace.find_by(slack_ws_id: team).app.id
      companion = Companion.find_or_create_by!(app_id: app_id, slack_user_id: user) do |c|
        c.app_id = app_id
        c.slack_user_id = user
      end
      companion
    end

    def participate_channel(user, channel_to_join, companion)
      unless App.exists?(bot_user_id: user)
        Participation.find_or_create_by!(companion_id: companion.id, channel_id: channel_to_join.id) do |p|
          p.companion_id = companion.id
          p.channel_id = channel_to_join.id
        end
      end
    end

    def reserve_messages(bot_token, companion, channel_to_join, messages)
      messages.each do |message|
        push_timing = message.push_timing

        participation_datetime = companion.participations.find_by(channel_id: channel_to_join.id).created_at
        push_datetime = push_datetime(participation_datetime, push_timing.in_x_days, push_timing.time)

        if push_datetime > Time.now
          schedule_message(bot_token, companion, push_datetime, message)
        end
      end
    end
end
