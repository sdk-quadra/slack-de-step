# frozen_string_literal: true

class Events::ChannelArchived
  include MessageBuilder
  def execute(bot_token, params)
    channel = params[:event][:channel]
    message_ids = Channel.find_by(slack_channel_id: channel).messages.map(&:id)
    build_delete_message(bot_token, message_ids) unless message_ids.nil?

    Channel.find_by(slack_channel_id: channel).destroy unless message_ids.nil?
  end
end
