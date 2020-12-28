# frozen_string_literal: true

class Events::ChannelCreated
  include CurlBuilder

  def execute(bot_token, params)
    # #
    # channelを新規作成した時の処理
    # #

    channel = params[:event][:channel]
    team = params[:team_id]

    # botをchannel登録する # channel_created => member_joined_channelの順に動くのは確実(botを埋めてからしかlogに出ないので)
    bot_join_to_channel(bot_token, channel)

    create_channel(bot_token, team, channel)

    members = conversations_members(bot_token, channel)

    participate_channel(members, channel)

    member_count(channel)
  end

  private
    def bot_join_to_channel(bot_token, channel)
      curl_exec(base_url: "https://slack.com/api/conversations.join", headers: { "Authorization": "Bearer " + bot_token },
                params: { "channel": channel[:id] })
    end

    def create_channel(bot_token, team, channel)
      name = channel_name(bot_token, channel[:id])
      app_id = Workspace.find_by(slack_ws_id: team).app.id

      Channel.find_or_create_by!(app_id: app_id, slack_channel_id: channel[:id]) do |c|
        c.app_id = app_id
        c.name = name
        c.slack_channel_id = channel[:id]
      end
    end

    def channel_name(bot_token, channel)
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
        # Participation.create(companion_id: companion_id, channel_id: channel_id) unless App.exists?(bot_user_id: member)

        unless App.exists?(bot_user_id: member)
          Participation.find_or_create_by!(companion_id: companion_id, channel_id: channel_id) do |p|
            p.companion_id = companion_id
            p.channel_id = channel_id
          end
        end
      end
    end

    def member_count(channel)
      member_count = Channel.find_by(slack_channel_id: channel[:id]).participations.count
      Channel.find_by(slack_channel_id: channel[:id]).update(member_count: member_count)
    end
end
