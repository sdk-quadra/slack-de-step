# frozen_string_literal: true

class RemoveColumnUserIdFromWorkspaces < ActiveRecord::Migration[6.0]
  def change
    remove_column :workspaces, :user_id, :integer
  end
end
