# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_workspace, only: [:new, :create, :edit, :update]
  before_action :set_channel, only: [:new, :create, :edit, :update]

  include CurlBuilder
  def new
    @message = Message.new
    @message.build_push_timing
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      build_message(@message)
    else
      render action: "new"
    end
  end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])
    if params[:delete_image]
      @message.image = nil
    end

    if @message.update(message_params)
      build_message(@message)
    else
      render action: "edit"
    end
  end

  def destroy
    message = params[:id]
    Message.destroy(message)
  end

  private

    def build_message(message)
      x_days_time = x_days_time(params)
      members = Channel.find(@channel.id).companions

      members.each do |member|
        participation_datetime = member.participations.find_by(channel_id: @channel.id).created_at
        push_datetime = push_datetime(participation_datetime, x_days_time)
        current_datetime = Time.now

        if push_datetime > current_datetime
          schedule_message(member.slack_user_id, push_datetime, message)
        end
      end
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

    def push_datetime(participation_datetime, x_days_time)
      push_date = participation_datetime + x_days_time[:in_x_days].to_i.days
      push_datetime = Time.parse(push_date.strftime("%Y-%m-%d #{x_days_time[:time]}"))
      push_datetime
    end

    def schedule_message(member, push_datetime, message)
      bot_token = @workspace.app.oauth_bot_token
      if params[:post_now]
        curl_exec(base_url: "https://slack.com/api/chat.postMessage",
                  params: { "token": bot_token, "channel": member, "text": message.message })
      elsif  message.image_url
        curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                  params: { "token": bot_token, "channel": member, "post_at": push_datetime.to_i, "blocks": "[{\"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{message.message}\"}, \"block_id\": \"text1\"}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]" })
      else
        curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                  params: { "token": bot_token, "channel": member, "post_at": push_datetime.to_i, "text": message.message })
      end
    end

    def message_params
      params.require(:message).permit(:message, :image,
                                    push_timing_attributes: [:id, :in_x_days, :time])
        .merge(channel_id: @channel.id)
    end

    def set_workspace
      @workspace = Workspace.find(params[:workspace_id])
    end

    def set_channel
      @channel = Channel.find(params[:channel_id])
    end
end
