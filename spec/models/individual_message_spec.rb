# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @message = FactoryBot.create(:message, channel_id: @channel.id)
    @companion = FactoryBot.create(:companion, app_id: @app.id)
  end

  it "individual_messageを登録できる事" do
    individual_message = IndividualMessage.new(
      companion_id: @companion.id,
      message_id: @message.id,
      scheduled_message_id: "test_scheduled_message_id",
      scheduled_datetime: Time.now
    )
    expect(individual_message).to be_valid
  end

  it "companion_idなしではindividual_messageを登録できない事" do
    individual_message = IndividualMessage.new(
      message_id: @message.id,
      scheduled_message_id: "test_scheduled_message_id",
      scheduled_datetime: Time.now
    )
    expect(individual_message).to_not be_valid
  end

  it "message_idなしではindividual_messageを登録できない事" do
    individual_message = IndividualMessage.new(
      companion_id: @companion.id,
      scheduled_message_id: "test_scheduled_message_id",
      scheduled_datetime: Time.now
    )
    expect(individual_message).to_not be_valid
  end

  it "scheduled_message_idなしではindividual_messageを登録できない事" do
    individual_message = IndividualMessage.new(
      companion_id: @companion.id,
      message_id: @message.id,
      scheduled_datetime: Time.now
    )
    expect(individual_message).to_not be_valid
  end

  it "scheduled_datetimeなしではindividual_messageを登録できない事" do
    individual_message = IndividualMessage.new(
      companion_id: @companion.id,
      message_id: @message.id,
      scheduled_message_id: "test_scheduled_message_id"
    )
    expect(individual_message).to_not be_valid
  end
end
