# frozen_string_literal: true

require "rails_helper"

RSpec.describe "channels", type: :system do
  before(:context) do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @companion = FactoryBot.create(:companion, app_id: @app.id)
  end

  context "sessionを伴うtest" do
    let(:rspec_session) { { workspace_id: @workspace.id } }

    it "ログアウトするとログインページに戻る事" do
      visit channel_path(@channel.id)
      click_link "ログアウト"
      expect(page).to have_content "\"〇日目\"の人にメッセージを送る"
    end

    it "channel一覧サイドバーにchannel名が表示されている事" do
      visit channel_path(@channel.id)
      expect(page).to have_selector ".channel__name", text: @channel.name
    end

    it "メッセージ新規追加でメッセージ作成画面に遷移する事" do
      visit channel_path(@channel.id)
      find(".channel-messages__add-message-link").click
      expect(page).to have_content "送信タイミング"
    end
  end
end
