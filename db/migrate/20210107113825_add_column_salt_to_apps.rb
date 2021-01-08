# frozen_string_literal: true

class AddColumnSaltToApps < ActiveRecord::Migration[6.0]
  def change
    add_column :apps, :salt, :string, null: false, default: ""
    change_column_default :apps, :salt, nil
  end
end
