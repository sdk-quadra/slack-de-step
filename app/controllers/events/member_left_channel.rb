# frozen_string_literal: true

class Events::MemberLeftChannel
  include MessageBuilder
  include ChannelBuilder

  def execute(bot_token, params)
    # #
    # channelからuserが退出した時の処理
    # #

    user = params[:event][:user]
    channel = params[:event][:channel]
    companion = Companion.find_by(slack_user_id: user)
    channel_to_leave = Channel.find_by(slack_channel_id: channel)

    destroy_participation(companion, channel_to_leave)

    member_count(channel)

    # message予約キャンセル
    cancel_reserved_messages(bot_token, user, channel)
  end

  private
    def destroy_participation(companion, channel_to_leave)
      participation = Participation.find_by(companion_id: companion.id, channel_id: channel_to_leave.id)
      participation.destroy unless participation.nil?
    end

    def cancel_reserved_messages(bot_token, user, channel)
      messages = Channel.find_by(slack_channel_id: channel).messages
      companion_id = Companion.find_by(slack_user_id: user).id

      messages.each.with_index(1) do |m, index|
        individual_message = m.individual_messages.find_by(companion_id: companion_id)
        delete_scheduled_message(bot_token, index, individual_message)

        destroy_individual_message(individual_message)
      end
    end

    def destroy_individual_message(individual_message)
      individual_message.destroy unless individual_message.nil?
    end
end
