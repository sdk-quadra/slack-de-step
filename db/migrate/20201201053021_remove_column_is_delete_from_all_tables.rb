class RemoveColumnIsDeleteFromAllTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :apps, :is_deleted, :boolean
    remove_column :channels, :is_deleted, :boolean
    remove_column :companions, :is_deleted, :boolean
    remove_column :individual_messages, :is_deleted, :boolean
    remove_column :messages, :is_deleted, :boolean
    remove_column :participations, :is_deleted, :boolean
    remove_column :possessions, :is_deleted, :boolean
    remove_column :push_timings, :is_deleted, :boolean
    remove_column :transceptions, :is_deleted, :boolean
    remove_column :users, :is_deleted, :boolean
    remove_column :workspaces, :is_deleted, :boolean
  end
end
