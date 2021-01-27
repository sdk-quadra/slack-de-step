# frozen_string_literal: true

class ScheduleMessage
  include Sidekiq::Worker
  sidekiq_options queue: :schedule_message, retry: 5

  include Builders::MessageBuilder
  MAX_WAIT_TIME = 5400

  def perform(bot_token, member, push_timestamp, message_id)
    message = Message.find(message_id)

    if message.image_url
      scheduled_message = curl_exec(base_url: SlackApis::Baseurl::CHAT_SCHEDULE_MESSAGE,
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": schedule_blocks_text_with_image(message) })
    else
      scheduled_message = curl_exec(base_url: SlackApis::Baseurl::CHAT_SCHEDULE_MESSAGE,
                                    params: { "token": bot_token, "channel": member, "post_at": push_timestamp, "blocks": schedule_blocks_text(message) })
    end

    IndividualMessage.save_individual_messages(member, message, scheduled_message)

    queues = Sidekiq::ScheduledSet.new

    if queues.size <= 0
      Message.update_all(modifiable: true)

    else
      modifiable_message = Message.where("modifiable = ? and updated_at < ?", "false", Time.now.ago(MAX_WAIT_TIME))
      modifiable_message.update_all(modifiable: true)
    end
  end
end
