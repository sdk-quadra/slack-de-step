# frozen_string_literal: true

class ChangeDatatypeAppIdToInteger < ActiveRecord::Migration[6.0]
  def change
    change_column :channels, :app_id, "integer USING app_id::integer"
    change_column :companions, :app_id, "integer USING app_id::integer"
  end
end
