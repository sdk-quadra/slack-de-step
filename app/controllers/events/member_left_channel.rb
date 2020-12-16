# frozen_string_literal: true

class Events::MemberLeftChannel
  include MessageBuilder

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

    messages.each.with_index(1) do |m, index|
      individual_message = m.individual_messages.find_by(companion_id: companion_id)

      delete_scheduled_message(bot_token, index, individual_message)

      individual_message.destroy unless individual_message.nil?
    end
  end

  def member_count(channel)
    member_count = Channel.find_by(slack_channel_id: channel).participations.count
    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end
end
