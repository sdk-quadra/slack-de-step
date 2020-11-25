# frozen_string_literal: true

class Events::ChannelDeleted
  include MessageBuilder

  def execute(bot_token, params)
    # #
    # channelを削除した時の処理
    # #

    channel = params[:event][:channel]

    message_ids = Channel.find_by(slack_channel_id: channel).messages.map(&:id)
    delete_scheduled_messages(bot_token, message_ids) unless message_ids.nil?

    Channel.find_by(slack_channel_id: channel).destroy unless message_ids.nil?
  end
end
