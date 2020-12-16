# frozen_string_literal: true

module MessageBuilder
  extend ActiveSupport::Concern
  include CurlBuilder
  MIN_POLLING_TIME = 5

  def test_message(bot_token, message)
    member = session[:authed_slack_user_id]
    if message.image_url
      curl_exec(base_url: "https://slack.com/api/chat.postMessage",
                params: { "token": bot_token, "channel": member, "blocks": "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{message.message}\"}}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]" })
    else
      curl_exec(base_url: "https://slack.com/api/chat.postMessage",
                params: { "token": bot_token, "channel": member, "blocks": "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{message.message}\" }}]" })
    end
  end

  def build_message(bot_token, message)
    message.update(modifiable: false)

    x_days_time = x_days_time(params)

    members = Channel.find(@channel.id).companions
    members.each.with_index(1) do |member, index|
      participation_datetime = member.participations.find_by(channel_id: @channel.id).created_at
      push_datetime = push_datetime(participation_datetime, x_days_time)

      if push_datetime > Time.now
        schedule_message(bot_token, member, push_datetime, message, index)
      end
    end
  end

  def push_datetime(participation_datetime, x_days_time)
    push_date = participation_datetime + x_days_time[:in_x_days].to_i.days
    push_datetime = Time.parse(push_date.strftime("%Y-%m-%d #{x_days_time[:time]}"))
    push_datetime
  end

  def schedule_message(bot_token, member, push_datetime, message, index = 1)
    ScheduleMessage.perform_in(index*MIN_POLLING_TIME.seconds, bot_token, member.slack_user_id, push_datetime.to_i, message.id)
  end

  def build_delete_message(bot_token, message_id)
    individual_messages = IndividualMessage.where(message_id: message_id)
    individual_messages.each.with_index(1) do |individual_message, index|
      scheduled_datetime = individual_message.scheduled_datetime
      if scheduled_datetime > Time.now
        delete_scheduled_message(bot_token, index, individual_message)
      end
    end
  end

  def delete_scheduled_message(bot_token, index, individual_message)
    DeleteScheduledMessage.perform_in(index*MIN_POLLING_TIME.seconds, bot_token, individual_message.companion.slack_user_id, individual_message.scheduled_message_id)
  end

  def save_individual_messages(member, message, scheduled_message)
    companion_id = Companion.find_by(slack_user_id: member).id
    message_id = message.id
    scheduled_message_id = JSON.parse(scheduled_message[0])["scheduled_message_id"]
    scheduled_timestamp = JSON.parse(scheduled_message[0])["post_at"]

    individual_message = IndividualMessage.find_or_initialize_by(message_id: message_id, companion_id: companion_id)
    individual_message.update_attributes(
      scheduled_message_id: scheduled_message_id,
      scheduled_datetime: Time.at(scheduled_timestamp)
    )
  end
end
