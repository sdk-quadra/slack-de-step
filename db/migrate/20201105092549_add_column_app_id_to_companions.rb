class AddColumnAppIdToCompanions < ActiveRecord::Migration[6.0]
  def change
    add_column :companions, :app_id, :string, null: false, default: ""
    change_column_default :companions, :app_id, nil
  end
end
