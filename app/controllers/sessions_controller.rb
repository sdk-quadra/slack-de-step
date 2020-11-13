# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :check_logined

  def create
    auth = request.env["omniauth.auth"]
    if auth.present?
      user = User.find_or_create_form_auth(request.env["omniauth.auth"])
      session[:user] = user
      session[:user_id] = user.id
      flash[:success] = "ユーザー認証が完了しました。"
      redirect_to workspaces_path
    else
      flash.now[:danger] = "ログインに失敗しました"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "ログアウトしました"
  end
end
