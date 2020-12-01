# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @message = FactoryBot.create(:message, channel_id: @channel.id)
  end

  it "messageを登録できる事" do
    expect(@message).to be_valid
  end

  it "channel_idなしではmessageを登録できない事" do
    message = Message.new(
      message: "メッセージ登録テスト"
    )
    expect(message).to_not be_valid
  end

  it "messageなしではmessageを登録できない事" do
    message = Message.new(
      channel_id: @channel.id
    )
    expect(message).to_not be_valid
  end
end
