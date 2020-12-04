# frozen_string_literal: true

class ChangeDatatypeUserIdAndWsIdOfPossessions < ActiveRecord::Migration[6.0]
  def change
    change_column_default :possessions, :user_id, nil
    change_column :possessions, :user_id, :integer, null: false
    change_column_default :possessions, :workspace_id, nil
    change_column :possessions, :workspace_id, :integer, null: false
  end
end
