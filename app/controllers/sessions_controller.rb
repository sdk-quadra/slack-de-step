# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :check_logined
  include ChannelBuilder
  include CurlBuilder

  def create
    code = params[:code]
    oauth_v2_access = oauth_v2_access(code)

    if oauth_v2_access.present?
      user = User.find_or_create_form_auth(oauth_v2_access)
      session[:user] = user
      session[:user_id] = user.id
      session[:authed_slack_user_id] = JSON.parse(oauth_v2_access[0])["authed_user"]["id"]

      slack_ws_id = JSON.parse(oauth_v2_access[0])["team"]["id"]
      workspace = Workspace.find_by(slack_ws_id: slack_ws_id)
      redirect_to workspace_channel_path(workspace.id, general_channel(workspace.app.id))
    else
      redirect_to root_path, flash:  { login_failed: "ログインに失敗しました" }
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, flash: { logout: "ログアウトしました" }
  end

  def oauth_v2_access(code)
    oauth_v2_access = curl_exec(base_url: "https://slack.com/api/oauth.v2.access", params: { "code": code, "client_id": ENV["SLACK_CLIENT_ID"], "client_secret": ENV["SLACK_CLIENT_SECRET"] })
    oauth_v2_access
  end
end
