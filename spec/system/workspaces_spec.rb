# frozen_string_literal: true

require "rails_helper"

RSpec.describe "workspaces", type: :system do
  before do
    driven_by(:rack_test)
  end

  before do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
  end

  it "workspace一覧を表示する事" do
    page.set_rack_session(user_id: @user.id)
    visit workspaces_path
    expect(page).to have_content "ワークスペースを選択"
  end

  it "general_channelに画面遷移する事" do
    page.set_rack_session(user_id: @user.id)
    visit workspaces_path
    click_link "workspace_icon"
    expect(page).to have_selector ".channel-messages__channel-name", text: "general"
  end
end
