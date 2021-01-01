# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_logined

  private
    def check_logined
      if session[:workspace_id] == nil
        redirect_to root_path
      end
    end
end
