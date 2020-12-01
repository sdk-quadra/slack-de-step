# frozen_string_literal: true

class ChangeDefaultMemberCountOfChannels < ActiveRecord::Migration[6.0]
  def change
    change_column_default :channels, :member_count, 0
  end
end
