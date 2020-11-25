# frozen_string_literal: true

class AddColumnSlackChannelIdAndDisplayToChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :slack_channel_id, :string
    add_column :channels, :display, :boolean
  end
end
