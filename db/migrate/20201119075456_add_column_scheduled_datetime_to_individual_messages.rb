class AddColumnScheduledDatetimeToIndividualMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :individual_messages, :scheduled_datetime, :datetime, null: false, default: -> { 'NOW()' }
    change_column_default :individual_messages, :scheduled_datetime, nil
  end
end
