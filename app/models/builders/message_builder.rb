# frozen_string_literal: true

module Builders
  module MessageBuilder
    include Builders::CurlBuilder
    include SlackApis::Blocks
    MIN_POLLING_TIME = 5

    def test_message(bot_token, message)
      member = session[:authed_slack_user_id]
      if message.image_url
        curl_exec(base_url: SlackApis::Baseurl::CHAT_POST_MESSAGE,
                  params: { "token": bot_token, "channel": member, "blocks": test_blocks_text_with_image(message) })
      else
        curl_exec(base_url: SlackApis::Baseurl::CHAT_POST_MESSAGE,
                  params: { "token": bot_token, "channel": member, "blocks": test_blocks_text(message) })
      end
    end

    def build_message(bot_token, message)
      in_x_days = params[:message][:push_timing_attributes][:in_x_days]
      time = params[:message][:push_timing_attributes][:time]

      members = Channel.find(@channel.id).companions
      members.each.with_index(1) do |member, index|
        participation_datetime = member.participations.find_by(channel_id: @channel.id).created_at
        push_datetime = push_datetime(participation_datetime, in_x_days, time)

        if push_datetime > Time.now
          schedule_message(bot_token, member, push_datetime, message, index)
        end
      end
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

    def schedule_message(bot_token, member, push_datetime, message, index = 1)
      message.update(modifiable: false)
      ScheduleMessage.perform_in(index * MIN_POLLING_TIME.seconds, bot_token, member.slack_user_id, push_datetime.to_i, message.id)
    end

    def delete_scheduled_message(bot_token, index, individual_message)
      DeleteScheduledMessage.perform_in(index * MIN_POLLING_TIME.seconds, bot_token, individual_message.companion.slack_user_id, individual_message.scheduled_message_id)
    end

    private
      def push_datetime(participation_datetime, in_x_days, time)
        push_date = participation_datetime + in_x_days.to_i.days
        Time.parse(push_date.strftime("%Y-%m-%d #{time}"))
      end
  end
end
