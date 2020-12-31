# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_logined

  private
    def check_logined
      if session[:user_id] == nil && !ENV["RSPEC"]
        redirect_to root_path
      end
    end
end
