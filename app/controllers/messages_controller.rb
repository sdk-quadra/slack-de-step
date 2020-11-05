# frozen_string_literal: true

class CurlBuilder
  def build(base_url:, method: "GET", params: {}, headers: {}, body_filename: nil, verbose: true, silent: true, options: "")
    url = base_url
    url += "?" + URI.encode_www_form(params) unless params.empty?
    cmd = "curl '#{url}'"
    cmd += " -d '@#{body_filename}'" if body_filename
    cmd += " " + headers.map { |k, v| "-H '#{k}: #{v}'" }.join(" ") + " " unless headers.empty?
    # cmd += " -v " if verbose
    cmd += " -s " if silent
    # cmd += options
    cmd
  end

  def exec(*args, **kwargs)
    cmd = build(*args, **kwargs)
    o, e, s = Open3.capture3(cmd)
  end
end

class MessagesController < ApplicationController
  def new
    @message = Message.new
    @message.build_push_timing
    @channel = params[:channel_id]
  end

  def create
    text = params[:message][:message]

    in_x_days = params[:message][:push_timing_attributes][:in_x_days]
    time_hour = params[:message][:push_timing_attributes]["time(4i)"]
    time_minute = params[:message][:push_timing_attributes]["time(5i)"]
    time_second = params[:message][:push_timing_attributes]["time(6i)"]
    time = "#{time_hour}:#{time_minute}:#{time_second}"
    image = params[:message][:image]

    message = Message.new
    message.message = text if text.present?
    message.channel_id = params[:channel_id]
    message.image = image if image.present?
    message.save!

    push_timing = PushTiming.new
    push_timing.message_id = message.id
    push_timing.in_x_days = in_x_days
    push_timing.time = Time.parse(time)
    push_timing.save!

    message_url = Message.find(message.id).image_url

    curl = CurlBuilder.new
    bot_token = ENV["OAUTH_BOT_TOKEN"]

    members = Channel.find(params[:channel_id]).companions.map(&:slack_user_id)

    members.each do |member|
      companion = Companion.find_by(slack_user_id: member)
      participation_datetime = companion.participations.where(companion_id: companion.id).where(channel_id: params[:channel_id]).map(&:created_at).first

      push_date = participation_datetime + in_x_days.to_i.days
      push_datetime = Time.parse(push_date.strftime("%Y-%m-%d #{time}"))
      current_datetime = Time.now

      if push_datetime > current_datetime
        curl.exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                  params: { "channel": member, "token": bot_token, "post_at": push_datetime.to_i, "blocks": "[{\"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{text}\"}, \"block_id\": \"text1\"}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]" })
      end
    end
  end

  def edit
    @message = Message.find(params[:id])
    @channel = params[:channel_id]
  end

  def update
    @message = Message.find(params[:id])
    @message_push_timing = Message.find(params[:id]).push_timing

    text = params[:message][:message]

    in_x_days = params[:message][:push_timing_attributes][:in_x_days]
    time_hour = params[:message][:push_timing_attributes]["time(4i)"]
    time_minute = params[:message][:push_timing_attributes]["time(5i)"]
    time_second = params[:message][:push_timing_attributes]["time(6i)"]
    time = "#{time_hour}:#{time_minute}:#{time_second}"
    image = params[:message][:image]

    @message.update(message: text) if text.present?
    @message.update(image: image) if image.present?
    @message.update(image: nil) if params["aaa"] == "1"

    @message_push_timing.update(in_x_days: in_x_days, time: time)

    curl = CurlBuilder.new
    bot_token = ENV["OAUTH_BOT_TOKEN"]

    members = Channel.find(params[:channel_id]).companions.map(&:slack_user_id)

    members.each do |member|
      companion = Companion.find_by(slack_user_id: member)
      participation_datetime = companion.participations.where(companion_id: companion.id).where(channel_id: params[:channel_id]).map(&:created_at).first

      push_date = participation_datetime + in_x_days.to_i.days
      push_datetime = Time.parse(push_date.strftime("%Y-%m-%d #{time}"))
      current_datetime = Time.now

      if push_datetime > current_datetime
        curl.exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                  params: { "token": bot_token, "channel": member, "post_at": push_datetime.to_i, "blocks": "[{\"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{text}\"}, \"block_id\": \"text1\"}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{@message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]" })
      end
    end
  end

  def destroy
    message = params[:id]
    Message.destroy(message)
  end
end
