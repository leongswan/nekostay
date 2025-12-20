class AddReportToCheckins < ActiveRecord::Migration[7.1]
  def change
    add_column :checkins, :report, :text
  end
end
