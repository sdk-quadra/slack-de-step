# frozen_string_literal: true

class ScheduleMessage
  include Sidekiq::Worker
  sidekiq_options queue: :schedule_message, retry: 5

  include MessageBuilder
  include SlackApiBaseurl
  include SlackApiBlocks

  def perform(bot_token, member, push_timestamp, message_id)
    message = Message.find(message_id)

    if message.image_url
      scheduled_message = curl_exec(base_url: url_chat_schedule_message,
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": schedule_blocks_text_with_image(message) })
    else
      scheduled_message = curl_exec(base_url: url_chat_schedule_message,
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": schedule_blocks_text(message) })
    end

    save_individual_messages(member, message, scheduled_message)

    # queueがなくなったら修正可能にする
    queues = Sidekiq::ScheduledSet.new

    if queues.size <= 0
      message.update(modifiable: true)
    end
  end
end
