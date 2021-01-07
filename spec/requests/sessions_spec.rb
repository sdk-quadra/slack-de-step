# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Messages", type: :request do
  it "bot_tokenを取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/oauth_v2_access.json"))
    session = SessionsController.new
    allow(session).to receive(:curl_exec).and_return(file)

    curl_exec = session.curl_exec(base_url: "https://slack.com/api/oauth.v2.access", params: { "code": "test_code", "client_id": ENV["SLACK_CLIENT_ID"], "client_secret": ENV["SLACK_CLIENT_SECRET"] })

    expect(curl_exec["ok"]).to eq true
  end

  it "user情報を取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/users_identity.json"))
    session = SessionsController.new
    allow(session).to receive(:curl_exec).and_return(file)

    curl_exec = session.curl_exec(base_url: "https://slack.com/api/users.identity", headers: { "Authorization": "Bearer " + "test_oauth_bot_token" })

    expect(curl_exec["ok"]).to eq true
  end

  it "channelリストを取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/conversations_list.json"))
    session = SessionsController.new
    allow(session).to receive(:curl_exec).and_return(file)

    curl_exec = session.curl_exec(base_url: "https://slack.com/api/conversations.list", headers: { "Authorization": "Bearer " + "test_oauth_bot_token" })

    expect(curl_exec["ok"]).to eq true
  end

  it "userリストを取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/users_list.json"))
    session = SessionsController.new
    allow(session).to receive(:curl_exec).and_return(file)

    curl_exec = session.curl_exec(base_url: "https://slack.com/api/users.list", headers: { "Authorization": "Bearer " + "test_oauth_bot_token" })

    expect(curl_exec["ok"]).to eq true
  end
end
