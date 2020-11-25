# frozen_string_literal: true

class AddColumnAppIdToChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :app_id, :string, null: false, default: ""
    change_column_default :channels, :app_id, nil
  end
end
