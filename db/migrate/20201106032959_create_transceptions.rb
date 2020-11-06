class CreateTransceptions < ActiveRecord::Migration[6.0]
  def change
    create_table :transceptions do |t|
      t.string :conversation_id, null: false
      t.boolean :is_read, default: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
