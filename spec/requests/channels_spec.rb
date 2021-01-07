# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Messages", type: :request do
  it "user情報を取得できる事" do
    file = ActiveSupport::JSON.decode(File.read("spec/fixtures/users_info.json"))
    channel = ChannelsController.new
    allow(channel).to receive(:curl_exec).and_return(file)

    curl_exec = channel.curl_exec(base_url: "https://slack.com/api/users.info?user=U01B6RZ33L5", headers: { "Authorization": "Bearer " + "test_oauth_bot_token" })

    expect(curl_exec["ok"]).to eq true
  end
end
