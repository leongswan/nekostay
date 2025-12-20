class ForceFixCheckinUserNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :checkins, :user_id, true
  end
end
