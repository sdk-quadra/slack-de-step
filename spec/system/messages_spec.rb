# frozen_string_literal: true

require "rails_helper"

RSpec.describe "messages", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
  end

  it "テキストメッセージを新規登録できる事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")

    find("#message_push_timing_attributes_in_x_days").set("1")
    find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

    click_button "登録"
    expect(page).to have_selector ".modal__title", text: "メッセージを登録しました"
  end

  it "現在時刻の5分以内はメッセージを登録できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(300).strftime("%H")
    minutes = Time.now.since(300).strftime("%M")

    find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

    click_button "登録"
    expect(page).to have_content "現在時刻より10分以上後を指定してください"
  end

  it "セットしたばかりのメッセージは編集、削除できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")

    find("#message_push_timing_attributes_in_x_days").set("1")
    find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

    click_button "登録"
    expect(page).to have_content "現在処理中です。編集、削除はしばらく経ってからにしてください"
  end

  it "テキスト未入力の場合は新規登録できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: ""
    click_button "登録"
    expect(page).to have_content "メッセージを入力してください"
  end

  it "テキストメッセージ+画像を新規登録できる事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
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
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: ""
    attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png"
    click_button "登録"
    expect(page).to have_content "メッセージを入力してください"
  end

  it "画像が2MBを超える場合は新規登録できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
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
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")

    find("#message_push_timing_attributes_in_x_days").set("1")
    find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")

    click_button "テスト送信"
    click_button "戻る"
    find(".back").click

    expect(page).to_not have_content "メッセージ登録テスト"
  end

  it "送信タイミングの日時がDB保存されている事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)

    find("#message_push_timing_attributes_in_x_days").set("1")
    find("#message_push_timing_attributes_time").set("23:45")

    fill_in "メッセージ *", with: "メッセージ登録テスト"
    click_button "登録"
    expect(page).to have_selector ".channel-message__post-datetime", text: "1日後の23:45"
  end

  it "画像選択時、画像削除ボタンが表示される事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    expect(find("#delete-image", visible: true)).to be_visible
  end

  it "画像選択時画像を削除し登録すると、DBに画像が保存されない事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"
    attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")

    find("#message_push_timing_attributes_in_x_days").set("1")
    find("#message_push_timing_attributes_time").set("#{hour}:#{minutes}")
    find(".message-form__delete-img").click

    click_button "削除する"
    click_button "登録"
    expect(find(".channel-message-data__image")).to be_visible
  end

  it "画像選択時、プレビューが表示される事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    expect(find("#preview", visible: true)).to be_visible
  end

  it "画像選択時、画像を削除するとプレビューが消える事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    attach_file "画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    find(".message-form__delete-img").click
    click_button "削除する"
    expect(find("#preview", visible: false)).to_not be_visible
  end
end
