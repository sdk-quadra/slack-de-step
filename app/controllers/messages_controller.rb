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

    @message_push_timing.update(in_x_days: in_x_days, time: time)

  end
end
