# frozen_string_literal: true

require "rails_helper"

RSpec.describe "messages", type: :system do
  before(:context) do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    # @appは予約されているのでit内で使う場合は別名で
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @companion = FactoryBot.create(:companion, app_id: @app.id)
    @participation = FactoryBot.create(:participation, channel_id: @channel.id, companion_id: @companion.id)
  end

  context "sessionを伴うtest" do
    let(:rspec_session) { { workspace_id: @workspace.id } }

    it "テキストメッセージを新規登録できる事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト"

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

      click_button "登録"
      expect(find("#overlay-commit-message", visible: true)).to be_visible
    end

    it "テキストメッセージを編集できる事" do
      @message = FactoryBot.create(:message, channel_id: @channel.id)
      @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)

      visit edit_channel_message_path(@channel.id, @message.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト_編集"

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

      click_button "登録"
      expect(find("#overlay-commit-message", visible: true)).to be_visible
    end

    it "現在時刻の5分以内はメッセージを登録できない事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト"

      hour = Time.now.since(300).strftime("%H")
      minutes = Time.now.since(300).strftime("%M")

      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

      click_button "登録"
      expect(page).to have_content "現在時刻より10分以上後を指定してください"
    end

    it "セットしたばかりのメッセージは編集、削除できない事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト"

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

      click_button "登録"
      expect(page).to have_content "現在処理中です。編集、削除はしばらく経ってからにしてください"
    end

    it "テキスト未入力の場合は新規登録できない事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: ""
      click_button "登録"
      expect(page).to have_content "メッセージを入力してください"
    end

    it "○日後を入力していない場合は新規登録できない事" do
      visit new_channel_message_path(@channel.id)
      find("#message_push_timing_attributes_time").set("23:45")

      fill_in "メッセージ *", with: "メッセージ登録テスト"
      click_button "登録"
      expect(page).to have_content "○日後を入力してください"
    end

    it "時刻を入力していない場合は新規登録できない事" do
      visit new_channel_message_path(@channel.id)
      find("#message_push_timing_attributes_in_x_days").set("1")

      fill_in "メッセージ *", with: "メッセージ登録テスト"
      click_button "登録"
      expect(page).to have_content "時刻を入力してください"
    end

    it "テキストメッセージ+画像を新規登録できる事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト"
      attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png"

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

      click_button "登録"
      expect(page).to have_content "メッセージ登録テスト"
      expect(find(".channel-message-data__image")).to be_visible
    end

    it "テキストメッセージなし+画像は新規登録できない事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: ""
      attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png"
      click_button "登録"
      expect(page).to have_content "メッセージを入力してください"
    end

    it "画像が2MBを超える場合は新規登録できない事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト"
      attach_file "画像を選択", "#{Rails.root}/spec/factories/images/large.jpeg"

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      find("#message_push_timing_attributes_in_x_days").set("#{hour}:#{minutes}")
      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

      click_button "登録"
      expect(page).to have_content "画像は2MB以下にしてください"
    end

    it "テスト送信してもDB保存されない事" do
      visit new_channel_message_path(@channel.id)
      fill_in "メッセージ *", with: "メッセージ登録テスト"

      hour = Time.now.since(5400).strftime("%H")
      minutes = Time.now.since(5400).strftime("%M")

      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")
      click_button "テスト送信"
      find("#overlay-test-submit").find(:xpath, ".//div/div[2]/button").click
      find(".back").click

      expect(page).to_not have_content "メッセージ登録テスト"
    end

    it "送信タイミングの日時がDB保存されている事" do
      visit new_channel_message_path(@channel.id)

      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("23:45")

      fill_in "メッセージ *", with: "メッセージ登録テスト"
      click_button "登録"
      expect(page).to have_selector ".channel-message__post-datetime", text: "1日後の23:45"
    end

    it "1つのchannelにメッセージを50以上登録できない事" do
      50.times {
        @message = FactoryBot.create(:message, channel_id: @channel.id)
        @push_timing = FactoryBot.create(:push_timing, message_id: @message.id)
      }

      visit new_channel_message_path(@channel.id)
      find("#message_push_timing_attributes_in_x_days").set("1")
      find("#message_push_timing_attributes_time").set("23:45")

      fill_in "メッセージ *", with: "メッセージ登録テスト"
      click_button "登録"
      expect(page).to have_content "最大メッセージ数は1つのchannelで50までです"
    end

    context "jsを伴うtest" do
      it "画像選択時、画像削除ボタンが表示される事", js: true do
        visit new_channel_message_path(@channel.id)
        attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
        expect(find("#delete-image", visible: true)).to be_visible
      end

      it "画像選択時画像を削除し登録すると、DBに画像が保存されない事", js: true do
        visit new_channel_message_path(@channel.id)
        fill_in "メッセージ *", with: "メッセージ登録テスト"
        attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true

        hour = Time.now.since(5400).strftime("%H")
        minutes = Time.now.since(5400).strftime("%M")

        find("#message_push_timing_attributes_in_x_days").set("1")
        find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}PM")
        find(".message-form__delete-img").click

        click_button "削除する"
        click_button "登録"

        expect(page).to have_no_selector(".channel-message-data__image")
      end

      it "画像選択時、プレビューが表示される事", js: true do
        visit new_channel_message_path(@channel.id)
        attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
        expect(find("#preview", visible: true)).to be_visible
      end

      it "画像選択時、画像を削除するとプレビューが消える事", js: true do
        visit new_channel_message_path(@channel.id)
        attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
        find(".message-form__delete-img").click
        click_button "削除する"
        expect(find("#preview", visible: false)).to_not be_visible
      end

      it "テスト送信後、modalが表示される事", js: true do
        visit new_channel_message_path(@channel.id)
        fill_in "メッセージ *", with: "メッセージ登録テスト"

        hour = Time.now.since(5400).strftime("%H")
        minutes = Time.now.since(5400).strftime("%M")

        find("#message_push_timing_attributes_in_x_days").set("1")
        find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}PM")
        click_button "テスト送信"

        expect(find("#overlay-test-submit", visible: true)).to be_visible
      end

      it "メッセージ登録後、modalが表示される事", js: true do
        visit new_channel_message_path(@channel.id)
        fill_in "メッセージ *", with: "メッセージ登録テスト"

        hour = Time.now.since(5400).strftime("%H")
        minutes = Time.now.since(5400).strftime("%M")

        find("#message_push_timing_attributes_in_x_days").set("1")
        find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}PM")
        click_button "登録"

        expect(find("#overlay-commit-message", visible: true)).to be_visible
      end
    end
  end
end
