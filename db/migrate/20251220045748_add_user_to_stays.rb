class AddUserToStays < ActiveRecord::Migration[7.1]
  def change
    add_reference :stays, :user, null: false, foreign_key: true
  end
end
