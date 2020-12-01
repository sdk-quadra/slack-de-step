# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @companion = FactoryBot.create(:companion, app_id: @app.id)
    @participation = FactoryBot.create(:participation, channel_id: @channel.id, companion_id: @companion.id)
  end

  it "participationを登録できる事" do
    expect(@participation).to be_valid
  end

  it "channel_idなしではparticipationを登録できない事" do
    participation = Participation.new(
      companion_id: @companion.id
    )
    expect(participation).to_not be_valid
  end

  it "companion_idなしではparticipationを登録できない事" do
    participation = Participation.new(
      channel_id: @channel.id
    )
    expect(participation).to_not be_valid
  end
end
