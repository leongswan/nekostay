class AddReceiverIdToMessages < ActiveRecord::Migration[7.1]
  def change
    # receiver_id がなければ追加する（usersテーブルを参照）
    unless column_exists?(:messages, :receiver_id)
      add_reference :messages, :receiver, null: false, foreign_key: { to_table: :users }
    end
  end
end
