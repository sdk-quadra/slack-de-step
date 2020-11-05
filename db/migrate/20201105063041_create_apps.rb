# frozen_string_literal: true

class CreateApps < ActiveRecord::Migration[6.0]
  def change
    create_table :apps do |t|
      t.integer :workspace_id, null: false
      t.string :oauth_bot_token
      t.string :bot_user_id
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
