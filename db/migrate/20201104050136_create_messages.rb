# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.integer :channel_id, null: false
      t.text :message
      t.string :image_url
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
