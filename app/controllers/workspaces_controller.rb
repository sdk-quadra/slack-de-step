# frozen_string_literal: true

class WorkspacesController < ApplicationController
  def index
    app_id = session[:app_id]
    @general_channel = Channel.where(name: "general").find_by(app_id: app_id)
  end
end
