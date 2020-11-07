# frozen_string_literal: true

class User < ApplicationRecord
  has_many :possessions, dependent: :destroy
  has_many :workspaces, through: :possessions
  extend CurlBuilder

  def self.find_or_create_form_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    name = auth[:info][:name]
    email = auth[:info][:email]

    if self.exists?(uid: uid, provider: provider)
      user = self.find_by(uid: uid, provider: provider)
    else
      user = self.create!(name: name, email: email, uid: uid, provider: provider)
      first_login(auth, user)
    end
    user
  end

  # private

  def self.first_login(auth, user)
    workspace = create_workspace(auth)
    app = create_app(auth, workspace)
    create_possession(user, workspace)
    create_channels(auth, app)
    create_companions(auth, app)
  end

  def self.create_workspace(auth)
    slack_ws_id = auth[:extra][:raw_info][:team_id]
    workspace = Workspace.find_or_create_by!(slack_ws_id: slack_ws_id) do |w|
      w.slack_ws_id = slack_ws_id
    end
    workspace
  end

  def self.create_app(auth, workspace)
    oauth_bot_token = auth[:extra][:bot_info][:bot_access_token]
    bot_user_id = auth[:extra][:bot_info][:bot_user_id]

    app = App.find_or_create_by!(workspace_id: workspace.id) do |a|
      a.workspace_id = workspace.id
      a.oauth_bot_token = oauth_bot_token
      a.bot_user_id = bot_user_id
    end
    app
  end

  def self.create_possession(user, workspace)
    possession = Possession.create!(user_id: user.id, workspace_id: workspace.id)
    possession
  end

  def self.create_channels(auth, app)
    oauth_bot_token = auth[:extra][:bot_info][:bot_access_token]
    conversations = curl_exec(base_url: "https://slack.com/api/conversations.list", headers: { "Authorization": "Bearer " + oauth_bot_token })
    conversations = JSON.parse(conversations[0])["channels"]

    conversations.each do |conversation|
      Channel.find_or_create_by!(app_id: app.id, slack_channel_id: conversation["id"]) do |channel|
        channel.app_id = app.id
        channel.slack_channel_id = conversation["id"]
        channel.name = conversation["name"]
        channel.name == "general" ? channel.display = true : channel.display = false
      end
    end
  end

  def self.create_companions(auth, app)
    oauth_bot_token = auth[:extra][:bot_info][:bot_access_token]
    users = curl_exec(base_url: "https://slack.com/api/users.list", headers: { "Authorization": "Bearer " + oauth_bot_token })
    users = JSON.parse(users[0])["members"]

    users.each do |user|
      unless user["name"] == "slackbot" || user["is_bot"] == true
        Companion.find_or_create_by!(app_id: app.id, slack_user_id: user["id"]) do |companion|
          companion.app_id = app.id
          companion.slack_user_id = user["id"]
        end
      end
    end
  end
end
