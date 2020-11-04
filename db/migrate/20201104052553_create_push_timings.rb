class CreatePushTimings < ActiveRecord::Migration[6.0]
  def change
    create_table :push_timings do |t|
      t.integer :message_id, null: false
      t.time :time, null: false
      t.integer :in_x_days, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
