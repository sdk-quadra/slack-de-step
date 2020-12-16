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
    seconds = Time.now.since(5400).strftime("%S")

    select hour, from: "message_push_timing_attributes_time_4i"
    select minutes, from: "message_push_timing_attributes_time_5i"
    select seconds, from: "message_push_timing_attributes_time_6i"

    click_button "登録"
    expect(page).to have_selector ".channel-message-data__content", text: "メッセージ登録テスト"
  end

  it "現在時刻の5分以内はメッセージを登録できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(30).strftime("%H")
    minutes = Time.now.since(30).strftime("%M")
    seconds = Time.now.since(30).strftime("%S")

    select hour, from: "message_push_timing_attributes_time_4i"
    select minutes, from: "message_push_timing_attributes_time_5i"
    select seconds, from: "message_push_timing_attributes_time_6i"

    click_button "登録"
    expect(page).to have_content "現在時刻より10分以上後を指定してください"
  end

  it "セットしたばかりのメッセージは編集、削除できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")
    seconds = Time.now.since(5400).strftime("%S")

    select hour, from: "message_push_timing_attributes_time_4i"
    select minutes, from: "message_push_timing_attributes_time_5i"
    select seconds, from: "message_push_timing_attributes_time_6i"

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
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/ruby.png"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")
    seconds = Time.now.since(5400).strftime("%S")

    select hour, from: "message_push_timing_attributes_time_4i"
    select minutes, from: "message_push_timing_attributes_time_5i"
    select seconds, from: "message_push_timing_attributes_time_6i"

    click_button "登録"
    expect(page).to have_content "メッセージ登録テスト"
    expect(find(".channel-message-data__img")).to be_visible
  end

  it "テキストメッセージなし+画像は新規登録できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: ""
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/ruby.png"
    click_button "登録"
    expect(page).to have_content "メッセージを入力してください"
  end

  it "画像が2MBを超える場合は新規登録できない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/large.jpeg"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")
    seconds = Time.now.since(5400).strftime("%S")

    select hour, from: "message_push_timing_attributes_time_4i"
    select minutes, from: "message_push_timing_attributes_time_5i"
    select seconds, from: "message_push_timing_attributes_time_6i"

    click_button "登録"
    expect(page).to have_content "画像は2MB以下にしてください"
  end

  it "テスト送信してもDB保存されない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"

    hour = Time.now.since(5400).strftime("%H")
    minutes = Time.now.since(5400).strftime("%M")
    seconds = Time.now.since(5400).strftime("%S")

    select hour, from: "message_push_timing_attributes_time_4i"
    select minutes, from: "message_push_timing_attributes_time_5i"
    select seconds, from: "message_push_timing_attributes_time_6i"

    click_button "テスト送信"
    expect(page).to_not have_content "メッセージ登録テスト"
  end

  it "送信タイミングの日時がDB保存されている事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    select 5, from: "message_push_timing_attributes_in_x_days"
    select 10, from: "message_push_timing_attributes_time_4i"
    select 20, from: "message_push_timing_attributes_time_5i"
    select 30, from: "message_push_timing_attributes_time_6i"
    fill_in "メッセージ *", with: "メッセージ登録テスト"
    click_button "登録"
    expect(page).to have_selector ".channel-message__post-datetime", text: "5日後の10:20:30"
  end

  it "画像選択時、画像削除ボタンが表示される事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    expect(find("#deleteImg", visible: true)).to be_visible
  end

  it "画像選択時画像を削除し登録すると、DBに画像が保存されない事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    click_button "画像を削除する"
    page.accept_confirm "本当に削除しますか？"
    click_button "登録"
    expect(find(".channel-message-data__img")).to be_visible
  end

  it "画像選択時、プレビューが表示される事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    expect(find("#preview", visible: true)).to be_visible
  end

  it "画像選択時、画像を削除するとプレビューが消える事", js: true do
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    attach_file "ここをクリックして画像を選択", "#{Rails.root}/spec/factories/images/ruby.png", make_visible: true
    click_button "画像を削除する"
    accept_confirm
    expect(find("#preview", visible: false)).to_not be_visible
  end
end
