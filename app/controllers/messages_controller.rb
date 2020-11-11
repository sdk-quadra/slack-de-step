# frozen_string_literal: true

class MessagesController < ApplicationController
  include CurlBuilder
  def new
    @channel = params[:channel_id]
    @message = Message.new
    @message.build_push_timing
    p "-------"
    p ENV["OAUTH_BOT_TOKEN"]
  end

  def create
    x_days_time = x_days_time(params)
    content = content(params)

    message = Message.new
    message.channel_id = params[:channel_id]
    message.message = content[:text] unless content[:text].empty?
    message.image = content[:image] if content[:image].present?
    message.save!

    push_timing = PushTiming.new
    push_timing.message_id = message.id
    push_timing.in_x_days = x_days_time[:in_x_days]
    push_timing.time = Time.parse(x_days_time[:time])
    push_timing.save!

    channel_id = params[:channel_id]
    members = channel_members(channel_id)

    members.each do |member|
      participation_datetime = participation_datetime(member, channel_id)
      push_datetime = push_datetime(participation_datetime, x_days_time)
      current_datetime = Time.now

      if push_datetime > current_datetime
        schedule_message(member, push_datetime, message)
      end
    end

  end

  def edit
    @message = Message.find(params[:id])
    @channel = params[:channel_id]
  end

  def update
    message = Message.find(params[:id])
    message_push_timing = Message.find(params[:id]).push_timing

    x_days_time = x_days_time(params)
    content = content(params)

    message.update(message: content[:text]) unless content[:text].empty?
    message.update(image: content[:image]) if content[:image].present?
    message.update(image: nil) if params["delete_image"] == "true"

    message_push_timing.update(in_x_days: x_days_time[:in_x_days], time: x_days_time[:time])

    channel_id = params[:channel_id]
    members = channel_members(channel_id)

    members.each do |member|
      participation_datetime = participation_datetime(member, channel_id)
      push_datetime = push_datetime(participation_datetime, x_days_time)
      current_datetime = Time.now

      if push_datetime > current_datetime
        schedule_message(member, push_datetime, message)
      end
    end
  end

  def destroy
    message = params[:id]
    Message.destroy(message)
  end

  private

    def channel_members(channel_id)
      members = Channel.find(channel_id).companions.map(&:slack_user_id)
      members
    end

    def x_days_time(params)
      x_days_time = {}
      x_days_time.store(:in_x_days, params[:message][:push_timing_attributes][:in_x_days])

      time_hour = params[:message][:push_timing_attributes]["time(4i)"]
      time_minute = params[:message][:push_timing_attributes]["time(5i)"]
      time_second = params[:message][:push_timing_attributes]["time(6i)"]

      x_days_time.store(:time, "#{time_hour}:#{time_minute}:#{time_second}")
      x_days_time
    end

    def content(params)
      content = {}
      content.store(:text, params[:message][:message])
      content.store(:image, params[:message][:image])
      content
    end

    def participation_datetime(member, channel_id)
      companion = Companion.find_by(slack_user_id: member)
      participation_datetime = companion.participations.where(companion_id: companion.id).find_by(channel_id: channel_id).created_at
      participation_datetime
    end

    def push_datetime(participation_datetime, x_days_time)
      push_date = participation_datetime + x_days_time[:in_x_days].to_i.days
      push_datetime = Time.parse(push_date.strftime("%Y-%m-%d #{x_days_time[:time]}"))
      push_datetime
    end

    def schedule_message(member, push_datetime, message)
      bot_token = ENV["OAUTH_BOT_TOKEN"]
      if message.image_url
        curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                  params: { "token": bot_token, "channel": member, "post_at": push_datetime.to_i, "blocks": "[{\"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{message.message}\"}, \"block_id\": \"text1\"}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]" })
      else
        curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                  params: { "token": bot_token, "channel": member, "post_at": push_datetime.to_i, "text": message.message })
      end

    end

end
