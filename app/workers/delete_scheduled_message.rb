# frozen_string_literal: true

class DeleteScheduledMessage
  include Sidekiq::Worker
  sidekiq_options queue: :delete_scheduled_message, retry: 5

  include MessageBuilder

  def perform(bot_token, member, scheduled_message_id)
    curl_exec(base_url: SlackApiBaseurl::CHAT_DELETE_SCHEDULED_MESSAGE,
              params: { "token": bot_token, "channel": member, "scheduled_message_id": scheduled_message_id })
  end
end
