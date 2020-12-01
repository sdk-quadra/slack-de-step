# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
  end

  it "workspaceを登録できる事" do
    expect(@workspace).to be_valid
  end

  it "slack_ws_idなしではworkspaceを登録できない事" do
    workspace = Workspace.new(
      name: "slack-de-step",
      icon_url: "https://a.slack-edge.com/80588/img/avatars-teams/ava_0023-132.png"
    )
    expect(workspace).to_not be_valid
  end

  it "nameなしではworkspaceを登録できない事" do
    workspace = Workspace.new(
      slack_ws_id: "T01FL373G1Z",
      icon_url: "https://a.slack-edge.com/80588/img/avatars-teams/ava_0023-132.png"
    )
    expect(workspace).to_not be_valid
  end

  it "icon_urlなしではworkspaceを登録できない事" do
    workspace = Workspace.new(
      slack_ws_id: "T01FL373G1Z",
      name: "slack-de-step"
    )
    expect(workspace).to_not be_valid
  end
end
