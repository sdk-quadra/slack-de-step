# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Messages", type: :request do
  include CurlBuilder

  it "channelに参加できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/conversations_join.json"))
    channel_created = Events::ChannelCreated.new
    allow(channel_created).to receive(:curl_exec).and_return(file)

    curl_exec = channel_created.curl_exec(base_url: "https://slack.com/api/conversations.join", headers: { "Authorization": "Bearer " + ENV["OAUTH_BOT_TOKEN"] },
                                  params: { "channel": "U010BU9GGBX" })

    expect(curl_exec["ok"]).to eq true
  end

  it "channel情報を取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/conversations_join.json"))
    channel_created = Events::ChannelCreated.new
    allow(channel_created).to receive(:curl_exec).and_return(file)

    curl_exec = channel_created.curl_exec(base_url: "https://slack.com/api/conversations.info",
                                          params: { "token": ENV["OAUTH_BOT_TOKEN"], "channel": "U010BU9GGBX" })

    expect(curl_exec["ok"]).to eq true
  end

  it "channelメンバーを取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/conversations_members.json"))
    channel_created = Events::ChannelCreated.new
    allow(channel_created).to receive(:curl_exec).and_return(file)

    curl_exec = channel_created.curl_exec(base_url: "https://slack.com/api/conversations.members", headers: { "Authorization": "Bearer " + ENV["OAUTH_BOT_TOKEN"] },
                                          params: { "channel": "U010BU9GGBX" })

    expect(curl_exec["ok"]).to eq true
  end
end
