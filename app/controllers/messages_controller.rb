# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_workspace, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_channel, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_bot_token, only: [:new, :create, :edit, :update, :destroy]

  include MessageBuilder

  def new
    @message = Message.new
    @message.build_push_timing
  end

  def create
    @message = Message.new(message_params)

    if params[:commit] == "テスト送信" && @message.valid?
      test_message(@bot_token, @message)
    elsif params[:commit] == "登録" && @message.save
      build_message(@bot_token, @message)
    else
      render action: "new"
    end
  end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])

    @message.image = nil if params[:delete_image]

    if params[:commit] == "テスト送信" && @message.valid?
      test_message(@bot_token, @message)
    elsif params[:commit] == "登録" && @message.update(message_params)

      # 以前の予約送信は消す
      delete_scheduled_messages(@bot_token, @message.id)

      build_message(@bot_token, @message)
    else
      render action: "edit"
    end
  end

  def destroy
    message_id = params[:id]

    delete_scheduled_messages(@bot_token, message_id)
    Message.destroy(message_id)
  end

  private
    def x_days_time(params)
      x_days_time = {}
      x_days_time.store(:in_x_days, params[:message][:push_timing_attributes][:in_x_days])

      time_hour = params[:message][:push_timing_attributes]["time(4i)"]
      time_minute = params[:message][:push_timing_attributes]["time(5i)"]
      time_second = params[:message][:push_timing_attributes]["time(6i)"]

      x_days_time.store(:time, "#{time_hour}:#{time_minute}:#{time_second}")
      x_days_time
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

    def set_bot_token
      @bot_token = Workspace.find(params[:workspace_id]).app.oauth_bot_token
    end
end
