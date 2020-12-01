# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @message = FactoryBot.create(:message, channel_id: @channel.id)
    @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)
  end

  it "push_timingを登録できる事" do
    expect(@push_timing).to be_valid
  end

  it "message_idなしではpush_timingを登録できない事" do
    push_timing = PushTiming.new(
      time: Time.now,
      in_x_days: 1
    )
    expect(push_timing).to_not be_valid
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
      time: Time.now
    )
    expect(push_timing).to_not be_valid
  end
end
