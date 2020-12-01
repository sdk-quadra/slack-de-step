# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
  end

  it "companionを登録できる事" do
    companion = Companion.new(
      app_id: @app.id,
      slack_user_id: "test_slack_user_id"
    )
    expect(companion).to be_valid
  end

  it "app_idなしではcompanionを登録できない事" do
    companion = Companion.new(
      slack_user_id: "test_slack_user_id"
    )
    expect(companion).to_not be_valid
  end

  it "slack_user_idなしではcompanionを登録できない事" do
    companion = Companion.new(
      app_id: @app.id,
    )
    expect(companion).to_not be_valid
  end
end
