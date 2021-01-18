# frozen_string_literal: true

class ScheduleMessage
  include Sidekiq::Worker
  sidekiq_options queue: :schedule_message, retry: 5

  include MessageBuilder

  def perform(bot_token, member, push_timestamp, message_id)
    message = Message.find(message_id)

    if message.image_url
      scheduled_message = curl_exec(base_url: SlackApiBaseurl::CHAT_SCHEDULE_MESSAGE,
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": schedule_blocks_text_with_image(message) })
    else
      scheduled_message = curl_exec(base_url: SlackApiBaseurl::CHAT_SCHEDULE_MESSAGE,
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": schedule_blocks_text(message) })
    end

    IndividualMessage.save_individual_messages(member, message, scheduled_message)

    # queueがなくなったら修正可能にする
    queues = Sidekiq::ScheduledSet.new

    if queues.size <= 0
      message.update(modifiable: true)
    end
  end
end
