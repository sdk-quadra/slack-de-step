# frozen_string_literal: true

class Events::MemberJoinedChannel
  # include MessageBuilder
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
    companion = Companion.register_companion(team, user)
    Participation.participate_channel(user, channel_to_join, companion)

    member_count(channel)

    # channelにセットされているmessageを取得
    messages = channel_to_join.messages
    Message.reserve_messages(bot_token, companion, channel_to_join, messages)
  end
end
