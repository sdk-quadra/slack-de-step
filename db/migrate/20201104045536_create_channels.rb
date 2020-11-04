class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.string :name, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
