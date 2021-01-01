# frozen_string_literal: true

class Possession < ApplicationRecord
  belongs_to :user
  belongs_to :workspace

  def self.create_possession(user, workspace)
    Possession.find_or_create_by!(user_id: user.id, workspace_id: workspace.id) do |p|
      p.user_id = user.id
      p.workspace_id = workspace.id
    end
  end
end
