class ChangeMoodColumnToInteger < ActiveRecord::Migration[7.0]
  def up
    # 古い string（文字）の箱を削除
    remove_column :checkins, :mood

    # 新しい integer（数字）の箱を追加
    add_column :checkins, :mood, :integer
  end

  def down
    remove_column :checkins, :mood
    add_column :checkins, :mood, :string
  end
end
