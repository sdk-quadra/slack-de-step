class AddColumnMemberCountToChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :member_count, :integer, null: false, default: 0
    change_column_default :channels, :member_count, nil
  end
end
