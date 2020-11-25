# frozen_string_literal: true

class CreatePossessions < ActiveRecord::Migration[6.0]
  def change
    create_table :possessions do |t|
      t.integer :user_id, default: false
      t.integer :workspace_id, default: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
