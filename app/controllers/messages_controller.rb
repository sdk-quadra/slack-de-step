# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_channel, :set_bot_token, :inaccessible_others_channel, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_message, :inaccessible_others_message,  only: [:edit, :update, :destroy]
  include MessageBuilder
  include CryptBuilder
  include OwnChecker

  def new
    @message = Message.new
    @message.build_push_timing
  end

  def create
    @message = Message.new(message_params)

    @message.image = nil if params["delete-image"]

    if params[:commit] == "テスト送信" && @message.valid?
      test_message(@bot_token, @message)
      flash.now[:test_submit] = true
      render action: "new"
    elsif params[:commit] == "登録" && @message.save
      build_message(@bot_token, @message)
      redirect_to channel_path(@channel), flash: { commit_message: true }
    else
      render action: "new"
    end
  end

  def edit
    inaccessible_while_processing(@message)
  end

  def update
    inaccessible_while_processing(@message)

    @message.image = nil if params["delete-image"]

    if params[:commit] == "テスト送信" && @message.update(message_params)
      test_message(@bot_token, @message)
      flash.now[:test_submit] = true
      render action: "edit"
    elsif params[:commit] == "登録" && @message.update(message_params)

      # 以前の予約送信は消す
      build_delete_message(@bot_token, @message.id)

      build_message(@bot_token, @message)
      redirect_to channel_path(@channel), flash: { commit_message: true }
    else
      render action: "edit"
    end
  end

  def destroy
    inaccessible_while_processing(@message)

    build_delete_message(@bot_token, @message.id)
    @message.destroy
    redirect_to channel_path(@channel)
  end

  private
    def message_params
      params.require(:message).permit(:message, :image, :image_cache,
                                      push_timing_attributes: [:id, :in_x_days, :time])
          .merge(channel_id: @channel.id)
    end

    def inaccessible_while_processing(message)
      redirect_to channel_path(@channel) if message.modifiable == false
    end

    def set_channel
      @channel = Channel.find(params[:channel_id])
    end

    def set_message
      @message = Message.find(params[:id])
    end

    def set_bot_token
      oauth_bot_token = App.find_by(workspace_id: session[:workspace_id]).oauth_bot_token
      @bot_token = decrypt_token(oauth_bot_token)
    end

    def inaccessible_others_channel
      check_channel_owner(session[:workspace_id], @channel.id)
    end

    def inaccessible_others_message
      check_message_owner(session[:workspace_id], @message.id)
    end
end
