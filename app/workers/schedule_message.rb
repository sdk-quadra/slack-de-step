# frozen_string_literal: true

class ScheduleMessage
  include Sidekiq::Worker
  sidekiq_options queue: :schedule_message, retry: 5

  include MessageBuilder

  def perform(bot_token, member, push_timestamp, message_id)
    message = Message.find(message_id)

    if message.image_url
      scheduled_message = curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": "[{\"block_id\": \"#{message.id}\", \"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{message.message}\"}}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]" })
    else
      scheduled_message = curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": "[{\"block_id\": \"#{message.id}\", \"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{message.message}\" }}]" })
    end

    save_individual_messages(member, message, scheduled_message)
  end
end
