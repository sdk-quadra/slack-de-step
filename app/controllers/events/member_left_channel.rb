class Events::MemberLeftChannel
  include CurlBuilder

  def execute(bot_token, params)

    # #
    # channelからuserが退出した時の処理
    # #

    user = params[:event][:user]
    channel = params[:event][:channel]

    companion = Companion.find_by(slack_user_id: user)

    channel_to_leave = Channel.find_by(slack_channel_id: channel)

    participation = Participation.find_by(companion_id: companion.id, channel_id: channel_to_leave.id)

    participation.destroy unless participation.nil?

    member_count(channel)

    messages = Channel.find_by(slack_channel_id: channel).messages

    companion_id = Companion.find_by(slack_user_id: user).id

    messages.each do |m|
      individual_message = m.individual_messages.find_by(companion_id: companion_id)

      curl_exec(base_url: "https://slack.com/api/chat.deleteScheduledMessage",
                params: { "token": bot_token, "channel": channel, "scheduled_message_id": individual_message.scheduled_message_id })

      individual_message.destroy unless individual_message.nil?
    end

  end

  def member_count(channel)
    member_count = Channel.find_by(slack_channel_id: channel).participations.count
    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end

end
