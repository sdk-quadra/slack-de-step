# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @message = FactoryBot.create(:message, channel_id: @channel.id)
    @transception = FactoryBot.create(:transception, message_id: @message.id)
  end

  it "transceptionを登録できる事" do
    expect(@transception).to be_valid
  end

  it "message_idなしではtransceptionを登録できない事" do
    transception = Transception.new(
      conversation_id: "test_conversation_id"
    )
    expect(transception).to_not be_valid
  end

  it "conversation_idなしではtransceptionを登録できない事" do
    transception = Transception.new(
      message_id: @message.id
    )
    expect(transception).to_not be_valid
  end
end
