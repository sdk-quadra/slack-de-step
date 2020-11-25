# frozen_string_literal: true

class AddColumnMessageIdToTransceptions < ActiveRecord::Migration[6.0]
  def change
    add_column :transceptions, :message_id, :integer, null: false, default: 1
    change_column_default :transceptions, :message_id, nil
  end
end
