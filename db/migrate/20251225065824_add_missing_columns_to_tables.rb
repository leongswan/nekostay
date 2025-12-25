class AddMissingColumnsToTables < ActiveRecord::Migration[7.1]
  def change
    # checkinsテーブルに food と mood を追加
    add_column :checkins, :food, :integer, default: 0
    add_column :checkins, :mood, :integer, default: 0

    # messagesテーブルに user_id を追加（なければ）
    unless column_exists?(:messages, :user_id)
      add_reference :messages, :user, null: false, foreign_key: true
    end
  end
end
