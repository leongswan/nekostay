# db/migrate/20250919131245_align_checkins_with_readme.rb
class AlignCheckinsWithReadme < ActiveRecord::Migration[7.1]
  def up
    # 追加（既にあるならスキップ）
    add_column :checkins, :meal,   :json  unless column_exists?(:checkins, :meal)
    add_column :checkins, :litter, :json  unless column_exists?(:checkins, :litter)
    add_column :checkins, :meds,   :json  unless column_exists?(:checkins, :meds)
    add_column :checkins, :memo,   :text  unless column_exists?(:checkins, :memo)

    # weight の精度を 6,2 に（既にそうなら DB 側でノーオペ）
    if column_exists?(:checkins, :weight)
      change_column :checkins, :weight, :decimal, precision: 6, scale: 2
    end

    # checked_at にインデックス（既にあればスキップ）
    add_index :checkins, :checked_at unless index_exists?(:checkins, :checked_at)

    # notes → memo に可能な限り移送（memo が空のレコードのみ）
    if column_exists?(:checkins, :notes) && column_exists?(:checkins, :memo)
      execute <<~SQL.squish
        UPDATE checkins
           SET memo = notes
         WHERE memo IS NULL AND notes IS NOT NULL
      SQL
    end

    # ※ mood / notes の削除は運用が固まってからでOK
    # remove_column :checkins, :mood  if column_exists?(:checkins, :mood)
    # remove_column :checkins, :notes if column_exists?(:checkins, :notes)
  end

  def down
    # 可能な範囲で戻す処理
    remove_index  :checkins, :checked_at if index_exists?(:checkins, :checked_at)
    change_column :checkins, :weight, :decimal               if column_exists?(:checkins, :weight)
    remove_column :checkins, :meal   if column_exists?(:checkins, :meal)
    remove_column :checkins, :litter if column_exists?(:checkins, :litter)
    remove_column :checkins, :meds   if column_exists?(:checkins, :meds)
    remove_column :checkins, :memo   if column_exists?(:checkins, :memo)
  end
end


