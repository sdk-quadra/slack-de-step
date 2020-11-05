# frozen_string_literal: true

class CurlBuilder
  def build(base_url:, method: "GET", params: {}, headers: {}, body_filename: nil, verbose: true, silent: true, options: "")
    url = base_url
    url += "?" + URI.encode_www_form(params) unless params.empty?
    cmd = "curl '#{url}'"
    cmd += " -d '@#{body_filename}'" if body_filename
    cmd += " " + headers.map { |k, v| "-H '#{k}: #{v}'" }.join(" ") + " " unless headers.empty?
    # cmd += " -v " if verbose
    cmd += " -s " if silent
    # cmd += options
    cmd
  end

  def exec(*args, **kwargs)
    cmd = build(*args, **kwargs)
    o, e, s = Open3.capture3(cmd)
  end
end

class User < ApplicationRecord
  has_one :workspace, dependent: :destroy

  def self.find_or_create_form_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    name = auth[:info][:name]
    email = auth[:info][:email]

    slack_ws_id = auth[:extra][:raw_info][:team_id]
    oauth_bot_token = auth[:extra][:bot_info][:bot_access_token]
    bot_user_id = auth[:extra][:bot_info][:bot_user_id]

    user = self.find_or_create_by!(provider: provider, uid: uid) do |user|
      user.name = name
      user.email = email
    end

    workspace = Workspace.find_or_create_by!(user_id: user.id, slack_ws_id: slack_ws_id) do |workspace|
      workspace.user_id = user.id
      workspace.slack_ws_id = slack_ws_id if slack_ws_id.present?
    end

    # workspace_idがすでにあれば、更新する
    app = App.find_or_initialize_by(workspace_id: workspace.id)
    app.update_attributes(
      oauth_bot_token: oauth_bot_token,
      bot_user_id: bot_user_id
    )

    ################
    # 新規ログインと同時にchannelとcompanionはその時点のデータを全登録
    ################
    curl = CurlBuilder.new
    conversation_lists = curl.exec(base_url: "https://slack.com/api/conversations.list", headers: { "Authorization": "Bearer " + oauth_bot_token })
    conversation_lists = JSON.parse(conversation_lists[0])["channels"]

    conversation_lists.each do |conversation|
      Channel.find_or_create_by!(app_id: app.id, slack_channel_id: conversation["id"]) do |channel|
        channel.slack_channel_id = conversation["id"]
        channel.name = conversation["name"]
        channel.app_id = app.id
        channel.name == "general" ? channel.display = true : channel.display = false
      end
    end

    user_lists = curl.exec(base_url: "https://slack.com/api/users.list", headers: { "Authorization": "Bearer " + oauth_bot_token })
    user_lists = JSON.parse(user_lists[0])["members"]

    user_lists.each do |user|
      unless user["name"] == "slackbot" || user["is_bot"] == true
        Companion.find_or_create_by!(app_id: app.id, slack_user_id: user["id"]) do |companion|
          companion.app_id = app.id
          companion.slack_user_id = user["id"]
        end
      end
    end
    user
  end
end
