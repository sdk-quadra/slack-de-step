# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_logined

  private
    def check_logined
      if action_name == "server"
      elsif ENV["RSPEC"]
      elsif session[:user_id] == nil
        redirect_to root_path
      end
    end
end
