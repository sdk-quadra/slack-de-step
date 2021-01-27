# frozen_string_literal: true

class Events::MemberJoinedChannel
  include Builders::ChannelBuilder

  def execute(bot_token, params)
    return if params[:authorizations][0][:is_bot] == "true"

    user = params[:event][:user]
    team = params[:team_id]
    channel = params[:event][:channel]
    channel_to_join = Channel.find_by(slack_channel_id: channel)

    unless App.exists?(bot_user_id: user)
      companion = Companion.register_companion(team, user)
      Participation.participate_channel(user, channel_to_join, companion)

      member_count(channel)

      messages = channel_to_join.messages
      Message.reserve_messages(bot_token, companion, channel_to_join, messages)
    end
  end
end
