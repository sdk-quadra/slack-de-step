# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @message = FactoryBot.create(:message, channel_id: @channel.id)
    @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)
    @companion = FactoryBot.create(:companion, app_id: @app.id)
    @participation = FactoryBot.create(:participation, channel_id: @channel.id, companion_id: @companion.id)
  end

  it "push_timingを登録できる事" do
    expect(@push_timing).to be_valid
  end

  it "message_idなしではpush_timingを登録できない事" do
    push_timing = PushTiming.new(
      time: Time.now.since(5400),
      in_x_days: 1
    )
    expect { push_timing.save }.to raise_error(NoMethodError)
  end

  it "timeなしではpush_timingを登録できない事" do
    push_timing = PushTiming.new(
      message_id: @message.id,
      in_x_days: 1
    )
    expect(push_timing).to_not be_valid
  end

  it "in_x_daysなしではpush_timingを登録できない事" do
    push_timing = PushTiming.new(
      message_id: @message.id,
      time: Time.now.since(5400)
    )
    expect(push_timing).to_not be_valid
  end

  it "現在時刻では投稿できない事" do
    push_timing = PushTiming.new(
      message_id: @message.id,
      time: Time.now,
      in_x_days: 1
    )
    expect(push_timing).to_not be_valid
  end
end
