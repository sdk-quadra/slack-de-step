# frozen_string_literal: true

class ChangeDatatypeNameAndEmailOfUsers < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :name, :string, null: false
    change_column :users, :email, :string, null: false
  end
end
