class CleanupOldStaysColumns < ActiveRecord::Migration[7.1]
  def change
    remove_column :stays, :user_id, :bigint
    remove_column :stays, :pet_name, :string
    remove_column :stays, :start_date, :date
    remove_column :stays, :end_date, :date
  end
end
