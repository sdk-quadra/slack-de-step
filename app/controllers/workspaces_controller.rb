# frozen_string_literal: true

class WorkspacesController < ApplicationController
  def index
    user_id = session[:user_id]
    possessions = Possession.where(user_id: user_id).map { |w| w.workspace_id }
    @workspaces = Workspace.where(id: possessions)
  end
end
