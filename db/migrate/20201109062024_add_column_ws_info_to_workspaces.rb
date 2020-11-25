# frozen_string_literal: true

class AddColumnWsInfoToWorkspaces < ActiveRecord::Migration[6.0]
  def change
    add_column :workspaces, :name, :string, null: false, default: ""
    add_column :workspaces, :icon_url, :string, null: false, default: ""
    change_column_default :workspaces, :name, nil
    change_column_default :workspaces, :icon_url, nil
  end
end
