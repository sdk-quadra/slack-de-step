# frozen_string_literal: true

class RemoveColumnDisplayFromChannels < ActiveRecord::Migration[6.0]
  def change
    remove_column :channels, :display, :boolean
  end
end
