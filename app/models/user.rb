# frozen_string_literal: true

class User < ApplicationRecord
  has_many :possessions, dependent: :destroy
  has_many :workspaces, through: :possessions

  validates :email, presence: true
  validates :name, presence: true

  extend CurlBuilder
  extend CryptBuilder

  def self.find_or_create_form_auth(auth)
    oauth_user_token = JSON.parse(auth[0])["authed_user"]["access_token"]

    users_identity = curl_exec(base_url: "https://slack.com/api/users.identity", headers: { "Authorization": "Bearer " + oauth_user_token })
    user_name = JSON.parse(users_identity[0])["user"]["name"]
    user_email = JSON.parse(users_identity[0])["user"]["email"]

    user = User.find_or_create_by!(email: user_email) do |u|
      u.name = user_name
      u.email = user_email
    end

    first_regist(JSON.parse(users_identity[0]), JSON.parse(auth[0]), user)

    user
  end

  def self.first_regist(users_identity, auth, user)
    workspace = create_workspace(users_identity)
    app = create_app(auth, workspace)
    create_possession(user, workspace)
    create_channels(auth, app)
    create_companions(auth, app)
  end

  def self.create_workspace(users_identity)
    slack_ws_id = users_identity["team"]["id"]
    name = users_identity["team"]["name"]
    icon_url = users_identity["team"]["image_132"]
    workspace = Workspace.find_or_create_by!(slack_ws_id: slack_ws_id) do |w|
      w.slack_ws_id = slack_ws_id
      w.name = name
      w.icon_url = icon_url
    end
    workspace
  end

  def self.create_app(auth, workspace)
    oauth_bot_token = auth["access_token"]
    bot_user_id = auth["bot_user_id"]
    api_app_id = auth["app_id"]

    encrypt_token = encrypt_token(oauth_bot_token)

    # workspace_idがすでにあれば、更新する
    app = App.find_or_initialize_by(workspace_id: workspace.id)
    app.update_attributes(
      oauth_bot_token: encrypt_token,
      bot_user_id: bot_user_id,
      api_app_id: api_app_id
    )
    app
  end

  def self.create_possession(user, workspace)
    Possession.find_or_create_by!(user_id: user.id, workspace_id: workspace.id) do |p|
      p.user_id = user.id
      p.workspace_id = workspace.id
    end
  end

  def self.create_channels(auth, app)
    oauth_bot_token = auth["access_token"]
    conversations = curl_exec(base_url: "https://slack.com/api/conversations.list", headers: { "Authorization": "Bearer " + oauth_bot_token })
    conversations = JSON.parse(conversations[0])["channels"]

    conversations.each do |conversation|
      Channel.find_or_create_by!(app_id: app.id, slack_channel_id: conversation["id"]) do |channel|
        channel.app_id = app.id
        channel.slack_channel_id = conversation["id"]
        channel.name = conversation["name"]
        channel.name == "general" ? channel.display = true : channel.display = false

        join_to_channel(oauth_bot_token, conversation)
      end
      # botをpublic channelに参加させる
      curl_exec(base_url: "https://slack.com/api/conversations.join", headers: { "Authorization": "Bearer " + oauth_bot_token },
                params: { "channel": conversation["id"] })
    end
  end

  def self.join_to_channel(bot_token, channel)
    curl_exec(base_url: "https://slack.com/api/conversations.join", headers: { "Authorization": "Bearer " + bot_token },
              params: { "channel": channel[:id] })
  end

  def self.create_companions(auth, app)
    oauth_bot_token = auth["access_token"]
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
