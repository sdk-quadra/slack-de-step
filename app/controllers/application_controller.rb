# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_logged_in

  private
    def check_logged_in
      unless session[:workspace_id]
        redirect_to root_path
      end
    end
end
