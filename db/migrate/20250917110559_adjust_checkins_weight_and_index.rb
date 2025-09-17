class AdjustCheckinsWeightAndIndex < ActiveRecord::Migration[7.1]
  def change
    # weight を decimal(6,2) に変更
    change_column :checkins, :weight, :decimal, precision: 6, scale: 2

    # checked_at にインデックス追加
    add_index :checkins, :checked_at unless index_exists?(:checkins, :checked_at)
  end
end