# frozen_string_literal: true

class ChangeDatatypeSlackChannelIdAndDisplayOfChannels < ActiveRecord::Migration[6.0]
  def change
    change_column :channels, :slack_channel_id, :string, null: false
    change_column :channels, :display, :boolean, default: false
  end
end
