# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :check_logged_in
  include ChannelBuilder
  include CurlBuilder

  def create
    code = params[:code]
    oauth_v2_access = User.oauth_v2_access(code)

    if oauth_v2_access.present?
      workspace = User.find_or_create_from_auth(oauth_v2_access)
      session[:workspace_id] = workspace.id
      session[:authed_slack_user_id] = JSON.parse(oauth_v2_access[0])["authed_user"]["id"]

      redirect_to channel_path(general_channel(workspace.app.id))
    else
      redirect_to root_path, flash:  { login_failed: "ログインに失敗しました" }
    end
  end

  def destroy
    session[:workspace_id] = nil
    redirect_to root_path, flash: { logout: "ログアウトしました" }
  end
end
