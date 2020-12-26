# frozen_string_literal: true

require "rails_helper"

RSpec.describe "channels", type: :system do
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

  it "ログアウトするとログインページに戻る事" do
    page.set_rack_session(user_id: @user.id)
    visit workspace_channel_path(@workspace.id, @channel.id)
    click_link "≡"
    expect(page).to have_content "\"〇日目\"の人にメッセージを送る"
  end

  it "channel一覧サイドバーにchannel名が表示されている事" do
    page.set_rack_session(user_id: @user.id)
    visit workspace_channel_path(@workspace.id, @channel.id)
    expect(page).to have_selector ".channel__name", text: @channel.name
  end

  it "メッセージ新規追加でメッセージ作成画面に遷移する事" do
    page.set_rack_session(user_id: @user.id)
    visit workspace_channel_path(@workspace.id, @channel.id)
    click_link "+ メッセージを追加"
    expect(page).to have_content "送信タイミング"
  end
end
