# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
  end

  it "channelを登録できる事" do
    expect(@channel).to be_valid
  end

  it "app_idなしではchannelを登録できない事" do
    channel = Channel.new(
      name: "general",
      slack_channel_id: "C01FYFNM9C1"
    )
    expect(channel).to_not be_valid
  end

  it "nameなしではchannelを登録できない事" do
    channel = Channel.new(
      app_id: @app.id,
      slack_channel_id: "C01FYFNM9C1"
    )
    expect(channel).to_not be_valid
  end

  it "slack_channel_idなしではchannelを登録できない事" do
    channel = Channel.new(
      app_id: @app.id,
      name: "general"
    )
    expect(channel).to_not be_valid
  end
end
