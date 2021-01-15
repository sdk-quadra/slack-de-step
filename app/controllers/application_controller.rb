# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_logged_in

  private
    def check_logged_in
      if session[:workspace_id] == nil
        redirect_to root_path
      end
    end
end
