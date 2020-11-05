class CreateCompanions < ActiveRecord::Migration[6.0]
  def change
    create_table :companions do |t|
      t.string :slack_user_id, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
