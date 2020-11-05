# frozen_string_literal: true

class CreateWorkspaces < ActiveRecord::Migration[6.0]
  def change
    create_table :workspaces do |t|
      t.integer :user_id, null: false
      t.string :slack_ws_id, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
