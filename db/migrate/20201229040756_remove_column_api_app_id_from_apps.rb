class RemoveColumnApiAppIdFromApps < ActiveRecord::Migration[6.0]
  def change
    remove_column :apps, :api_app_id, :string
  end
end
