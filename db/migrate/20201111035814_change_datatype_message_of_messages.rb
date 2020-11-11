class ChangeDatatypeMessageOfMessages < ActiveRecord::Migration[6.0]
  def change
    change_column :messages, :message, :text, null: false, default: ""
    change_column_default :messages, :message, nil
  end
end
