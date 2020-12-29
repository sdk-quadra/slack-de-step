# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_workspace, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_channel, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_bot_token, only: [:new, :create, :edit, :update, :destroy]

  include MessageBuilder
  include CryptBuilder

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
      redirect_to workspace_channel_path(@workspace, @channel), flash: { commit_message: true }
    else
      render action: "new"
    end
  end

  def edit
    @message = Message.find(params[:id])
    inaccessible_while_processing(@message)
  end

  def update
    @message = Message.find(params[:id])
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
      redirect_to workspace_channel_path(@workspace, @channel), flash: { commit_message: true }
    else
      render action: "edit"
    end
  end

  def destroy
    @message = Message.find(params[:id])
    inaccessible_while_processing(@message)

    build_delete_message(@bot_token, @message.id)
    @message.destroy
    redirect_to workspace_channel_path(@workspace, @channel)
  end

  private
    def message_params
      params.require(:message).permit(:message, :image,
                                      push_timing_attributes: [:id, :in_x_days, :time])
          .merge(channel_id: @channel.id)
    end

    def inaccessible_while_processing(message)
      redirect_to workspace_channel_path(@workspace, @channel) if message.modifiable == false
    end

    def set_workspace
      @workspace = Workspace.find(params[:workspace_id])
    end

    def set_channel
      @channel = Channel.find(params[:channel_id])
    end

    def set_bot_token
      @bot_token = decrypt_token(Workspace.find(params[:workspace_id]).app.oauth_bot_token)
    end
end
