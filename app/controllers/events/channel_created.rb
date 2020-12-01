# frozen_string_literal: true

class Events::ChannelCreated
  include CurlBuilder

  def execute(bot_token, params)
    # #
    # channelを新規作成した時の処理
    # #

    channel = params[:event][:channel]
    api_app = params[:api_app_id]

    # botをchannel登録する # channel_created => member_joined_channelの順に動くのは確実(botを埋めてからしかlogに出ないので)

    join_to_channel(bot_token, channel)

    create_channel(api_app, channel)

    members = conversations_members(bot_token, channel)

    participate_channel(members, channel)
  end

  private
    def join_to_channel(bot_token, channel)
      curl_exec(base_url: "https://slack.com/api/conversations.join", headers: { "Authorization": "Bearer " + bot_token },
                params: { "channel": channel[:id] })
    end

    def create_channel(api_app, channel)
      name = channel_name(api_app, channel[:id])
      api_app_id = App.find_by(api_app_id: api_app).id

      Channel.find_or_create_by!(app_id: api_app_id, slack_channel_id: channel[:id]) do |c|
        c.app_id = api_app_id
        c.name = name
        c.slack_channel_id = channel[:id]
      end
    end

    def channel_name(api_app, channel)
      bot_token = App.find_by(api_app_id: api_app).oauth_bot_token
      conversation_info = curl_exec(base_url: "https://slack.com/api/conversations.info",
                                    params: { "token": bot_token, "channel": channel })
      channel_name = JSON.parse(conversation_info[0])["channel"]["name"]
      channel_name
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
end
