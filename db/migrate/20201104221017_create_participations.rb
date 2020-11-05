# frozen_string_literal: true

class CreateParticipations < ActiveRecord::Migration[6.0]
  def change
    create_table :participations do |t|
      t.integer :channel_id, null: false
      t.integer :companion_id, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
