# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Messages", type: :request do
  include CurlBuilder

  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
    @message = FactoryBot.create(:message, channel_id: @channel.id)
  end

  it "テスト送信できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/post_message.json"))
    message = MessagesController.new
    allow(message).to receive(:curl_exec).and_return(file)

    curl_exec = message.curl_exec(base_url: "https://slack.com/api/chat.postMessage",
                                  params: { "token": ENV["OAUTH_BOT_TOKEN"], "channel": "U010BU9GGBX", "blocks": "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{@message.message}\" }}]" })

    expect(curl_exec["ok"]).to eq true
  end

  it "スケジュール送信できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/schedule_message.json"))
    message = MessagesController.new
    allow(message).to receive(:curl_exec).and_return(file)

    curl_exec = message.curl_exec(base_url: "https://slack.com/api/chat.scheduleMessage",
                                  params: { "token": ENV["OAUTH_BOT_TOKEN"], "channel": "U010BU9GGBX", "post_at": "1617202800", "blocks": "[{\"block_id\": \"#{@message.id}\", \"type\": \"section\",\"text\": {\"type\": \"plain_text\", \"text\": \"#{@message.message}\" }}]" })

    expect(curl_exec["ok"]).to eq true
  end

  it "スケジュール送信を削除できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/delete_scheduled_message.json"))
    message = MessagesController.new
    allow(message).to receive(:curl_exec).and_return(file)

    curl_exec = message.curl_exec(base_url: "https://slack.com/api/chat.deleteScheduledMessage",
                                  params: { "token": ENV["OAUTH_BOT_TOKEN"], "channel": "U010BU9GGBX", "scheduled_message_id": "Q01EYP5BLF9" })

    expect(curl_exec["ok"]).to eq true
  end

end
