# frozen_string_literal: true

require "rails_helper"

RSpec.describe "messages", type: :system do
  before do
    # driven_by(:rack_test)
  end

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
    click_button "登録"
    expect(page).to have_selector ".channel-message-data__content", text: "メッセージ登録テスト"
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
    click_button "登録"
    expect(page).to have_content "画像は2 MB以下にしてください"
  end

  it "テスト送信してもDB保存されない事" do
    page.set_rack_session(user_id: @user.id)
    visit new_workspace_channel_message_path(@workspace.id, @channel.id)
    fill_in "メッセージ *", with: "メッセージ登録テスト"
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

end
