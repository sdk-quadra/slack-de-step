# frozen_string_literal: true

class Events::ChannelCreated
  include CurlBuilder
  include ChannelBuilder

  def execute(bot_token, params)
    # #
    # channelを新規作成した時の処理
    # #

    channel = params[:event][:channel][:id]
    team = params[:team_id]

    # botをchannel登録する。botがchannelに入らないとchannelのeventを検知できないので
    Channel.bot_join_to_new_channel(bot_token, channel)

    Channel.create_channel(bot_token, team, channel)
    channel_members = Channel.channel_members(bot_token, channel)
    Participation.participate_new_channel(channel_members, channel)
    member_count(channel)
  end
end
