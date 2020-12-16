# frozen_string_literal: true

class AddColumnModifiableToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :modifiable, :boolean, default: true
    change_column_default :messages, :modifiable, true
  end
end
