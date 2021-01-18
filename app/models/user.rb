# frozen_string_literal: true

class User < ApplicationRecord
  has_many :possessions, dependent: :destroy
  has_many :workspaces, through: :possessions

  validates :email, presence: true

  extend CurlBuilder

  class << self
    def find_or_create_from_auth(auth)
      oauth_user_token = JSON.parse(auth[0])["authed_user"]["access_token"]
      users_identity = users_identity(oauth_user_token)

      # 同じworkspaceでもそれまでと違うuserがログインする場合を考慮し、create_workspaceの先にcreate_userする
      user = create_user(JSON.parse(users_identity[0]))
      workspace = Workspace.create_workspace(JSON.parse(users_identity[0]))

      if workspace.new_record?
        workspace.save!
        first_registration(JSON.parse(auth[0]), user, workspace)
      end

      workspace
    end

    def first_registration(auth, user, workspace)
      app = App.create_app(auth, workspace)

      Possession.create_possession(user, workspace)
      Channel.create_channels(auth, app)
      Companion.create_companions(auth, app)
    end

    def create_user(users_identity)
      user_email = users_identity["user"]["email"]

      user = User.find_or_create_by!(email: user_email) do |u|
        u.email = user_email
      end
      user
    end

    def users_identity(oauth_user_token)
      curl_exec(base_url: SlackApiBaseurl::USERS_IDENTITY,
                headers: { "Authorization": "Bearer " + oauth_user_token })
    end

    def users_info(oauth_bot_token, bot_user_id)
      curl_exec(base_url: SlackApiBaseurl::USERS_INFO, headers: { "Authorization": "Bearer " + oauth_bot_token },
                params: { "user": bot_user_id })
    end

    def users_list(oauth_bot_token)
      curl_exec(base_url: SlackApiBaseurl::USERS_LIST, headers: { "Authorization": "Bearer " + oauth_bot_token })
    end

    def oauth_v2_access(code)
      curl_exec(base_url: SlackApiBaseurl::OAUTH_V2_ACCESS, params: { "code": code, "client_id": ENV["SLACK_CLIENT_ID"], "client_secret": ENV["SLACK_CLIENT_SECRET"] })
    end
  end
end
