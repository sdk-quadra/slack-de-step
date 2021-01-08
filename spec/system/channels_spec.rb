# frozen_string_literal: true

require "rails_helper"

RSpec.describe "channels", type: :system do
  # before do
  before(:context) do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    # @appは予約されているのでit内で使う場合は別名で
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

    it "channel一覧サイドバーの一番上はgeneral channelである事" do
      visit channel_path(@channel.id)
      expect(first(".channel__name")).to have_content "general"
    end

    it "メッセージ新規追加でメッセージ作成画面に遷移する事" do
      visit channel_path(@channel.id)
      find(".channel-messages__add-message-link").click
      expect(page).to have_content "送信タイミング"
    end

    it "メッセージがセットされていない場合は、作成を促すメッセージを表示する事" do
      visit channel_path(@channel.id)
      expect(page).to have_content "コミュニケーションを開始しましょう"
    end

    it "channelを選択した時に、セットされたメッセージ内容が表示されている事" do
      @message = FactoryBot.create(:message, channel_id: @channel.id)
      @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)

      visit channel_path(@channel.id)
      first(".channel__name").click
      expect(page).to have_content "メッセージ登録テスト"
    end

    it "channelを選択した時に、セットされたメッセージ時刻が表示されている事" do
      @message = FactoryBot.create(:message, channel_id: @channel.id)
      @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      visit channel_path(@channel.id)
      first(".channel__name").click
      expect(page).to have_content "1日後の#{hour}:#{minutes}"
    end

    context "seleniumを使う必要があるテスト" do
      it "channel一覧サイドバーの人数について、をクリックすると、modalが開く事", js: true do
        visit channel_path(@channel.id)
        find(".fa-info").click
        expect(find("#overlay-channels-info", visible: true)).to be_visible
      end

      it "メッセージのメニューアイコンをクリックすると編集、削除メニューが表示される事", js: true do
        @message = FactoryBot.create(:message, channel_id: @channel.id)
        @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)

        visit channel_path(@channel.id)
        find(".channel-message-data__modification-icon").click
        expect(find(".channel-message-data__modification-menu", visible: true)).to be_visible
      end

      it "メッセージの編集をクリックすると、編集画面へ飛ぶ事", js: true do
        @message = FactoryBot.create(:message, channel_id: @channel.id)
        @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)

        visit channel_path(@channel.id)
        find(".channel-message-data__modification-icon").click
        click_link "編集"
        expect(page).to have_content "送信タイミング *"
      end

      it "メッセージの削除をクリックすると、対象のメッセージを削除する事", js: true do
        @message = FactoryBot.create(:message, channel_id: @channel.id)
        @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)

        visit channel_path(@channel.id)
        find(".channel-message-data__modification-icon").click
        find(".channel-message-data__modification-list", text: "削除").click
        click_button "削除する"
        expect(page).to_not have_content "メッセージ登録テスト"
      end
    end
  end
end
