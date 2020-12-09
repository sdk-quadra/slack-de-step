# frozen_string_literal: true

class WorkspacesController < ApplicationController
  def index
    workspace = Workspace.find_by(slack_ws_id: session[:workspace_id])
    redirect_to workspace_channel_path(workspace.id, general_channel(workspace.app.id))
  end

  def general_channel(app_id)
    Channel.where(name: "general").find_by(app_id: app_id)
  end
end
