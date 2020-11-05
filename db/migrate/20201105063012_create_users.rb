# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :uid, null: false
      t.string :provider, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
