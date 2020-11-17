class AddColumnApiAppIdToApps < ActiveRecord::Migration[6.0]
  def change
    add_column :apps, :api_app_id, :string, null: false, default: ""
    change_column_default :apps, :api_app_id, nil
  end
end
