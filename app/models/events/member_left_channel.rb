# frozen_string_literal: true

class Events::MemberLeftChannel
  include ChannelBuilder

  def execute(bot_token, params)
    # #
    # channelからuserが退出した時の処理
    # #

    user = params[:event][:user]
    channel = params[:event][:channel]
    companion = Companion.find_by(slack_user_id: user)
    channel_to_leave = Channel.find_by(slack_channel_id: channel)

    Participation.destroy_participation(companion, channel_to_leave)

    member_count(channel)

    # message予約キャンセル
    Message.cancel_reserved_messages(bot_token, user, channel)
  end
end
