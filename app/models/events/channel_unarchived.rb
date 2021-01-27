# frozen_string_literal: true

class Events::ChannelUnarchived
  include Builders::CurlBuilder
  include Builders::ChannelBuilder

  def execute(bot_token, params)
    channel = params[:event][:channel]
    team = params[:team_id]
    Channel.bot_join_to_new_channel(bot_token, channel)

    Channel.create_channel(bot_token, team, channel)
    channel_members = Channel.channel_members(bot_token, channel)
    Participation.participate_new_channel(channel_members, channel)
    member_count(channel)
  end
end
