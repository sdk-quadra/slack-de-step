class CreateIndividualMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_messages do |t|
      t.integer :message_id, null: false
      t.integer :companion_id, null: false
      t.string :scheduled_message_id, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
