# frozen_string_literal: true

class User < ApplicationRecord
  has_many :possessions, dependent: :destroy
  has_many :workspaces, through: :possessions

  validates :email, presence: true
  validates :name, presence: true

  extend CurlBuilder
  extend CryptBuilder
  extend SlackApiBaseurl

  def self.find_or_create_form_auth(auth)
    oauth_user_token = JSON.parse(auth[0])["authed_user"]["access_token"]

    users_identity = users_identity(oauth_user_token)
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

    encrypt_token = encrypt_token(oauth_bot_token)

    # workspace_idがすでにあれば、更新する
    app = App.find_or_initialize_by(workspace_id: workspace.id)
    app.update_attributes(
      oauth_bot_token: encrypt_token,
      bot_user_id: bot_user_id
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
    conversations_list = conversations_list(oauth_bot_token)
    conversations = JSON.parse(conversations_list[0])["channels"]

    conversations.each do |conversation|
      Channel.find_or_create_by!(app_id: app.id, slack_channel_id: conversation["id"]) do |channel|
        channel.app_id = app.id
        channel.slack_channel_id = conversation["id"]
        channel.name = conversation["name"]
      end
      # botをpublic channelに参加させる
      bot_join_to_channel(oauth_bot_token, conversation)
    end
  end

  def self.create_companions(auth, app)
    oauth_bot_token = auth["access_token"]
    users_list = users_list(oauth_bot_token)
    users = JSON.parse(users_list[0])["members"]

    users.each do |user|
      unless user["name"] == "slackbot" || user["is_bot"] == true
        Companion.find_or_create_by!(app_id: app.id, slack_user_id: user["id"]) do |companion|
          companion.app_id = app.id
          companion.slack_user_id = user["id"]
        end
      end
    end
  end

  def self.bot_join_to_channel(bot_token, channel)
    curl_exec(base_url: url_conversations_join, headers: { "Authorization": "Bearer " + bot_token },
              params: { "channel": channel[:id] })
  end

  def self.conversations_list(oauth_bot_token)
    conversations_list = curl_exec(base_url: url_conversations_list, headers: { "Authorization": "Bearer " + oauth_bot_token })
    conversations_list
  end

  def self.users_list(oauth_bot_token)
    users_list = curl_exec(base_url: url_users_list, headers: { "Authorization": "Bearer " + oauth_bot_token })
    users_list
  end

  def self.users_identity(oauth_user_token)
    users_identity = curl_exec(base_url: url_users_identity, headers: { "Authorization": "Bearer " + oauth_user_token })
    users_identity
  end
end
