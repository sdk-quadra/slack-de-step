class Events::ChannelDeleted
  include MessageBuilder

  def execute(bot_token, params)
    # #
    # channelを削除した時の処理
    # #

    api_app = params[:api_app_id]
    channel = params[:event][:channel]

    # bot_token = App.find_by(api_app_id: api_app).oauth_bot_token
    message_ids = Channel.find_by(slack_channel_id: channel).messages.map(&:id)
    delete_scheduled_messages(bot_token, message_ids) unless message_ids.nil?

    Channel.find_by(slack_channel_id: channel).destroy unless message_ids.nil?

  end

end
