class AddMissingColumnsToTables < ActiveRecord::Migration[7.1]
  def change
    # checkinsテーブルに food カラムがない場合のみ追加
    unless column_exists?(:checkins, :food)
      add_column :checkins, :food, :integer, default: 0
    end

    # checkinsテーブルに mood カラムがない場合のみ追加
    unless column_exists?(:checkins, :mood)
      add_column :checkins, :mood, :integer, default: 0
    end

    # messagesテーブルに user_id がない場合のみ追加
    unless column_exists?(:messages, :user_id)
      add_reference :messages, :user, null: false, foreign_key: true
    end
  end
end
