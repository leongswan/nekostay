class AlignCheckinsWithReadme < ActiveRecord::Migration[7.1]
  def change
    add_column :checkins, :meal,   :json unless column_exists?(:checkins, :meal)
    add_column :checkins, :litter, :json unless column_exists?(:checkins, :litter)
    add_column :checkins, :meds,   :json unless column_exists?(:checkins, :meds)
    add_column :checkins, :memo,   :text unless column_exists?(:checkins, :memo)

    # 既存 notes → memo へ可能なら移行
    reversible do |dir|
      dir.up do
        if column_exists?(:checkins, :notes) && column_exists?(:checkins, :memo)
          execute "UPDATE checkins SET memo = notes WHERE memo IS NULL AND notes IS NOT NULL"
        end
      end
    end

    # 不要なら削除（運用が固まったらコメントアウトを外す）
    # remove_column :checkins, :mood,  :string if column_exists?(:checkins, :mood)
    # remove_column :checkins, :notes, :text   if column_exists?(:checkins, :notes)
  end
end

