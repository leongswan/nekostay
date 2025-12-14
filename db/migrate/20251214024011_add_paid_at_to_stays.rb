class AddPaidAtToStays < ActiveRecord::Migration[7.1]
  def change
    add_column :stays, :paid_at, :datetime
  end
end
