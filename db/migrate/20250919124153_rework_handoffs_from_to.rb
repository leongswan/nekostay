class ReworkHandoffsFromTo < ActiveRecord::Migration[7.1]
  def change
    # 旧カラムがあれば除去
    if column_exists?(:handoffs, :stay_id)
      remove_reference :handoffs, :stay, foreign_key: true
    end
    remove_column :handoffs, :completed, :boolean if column_exists?(:handoffs, :completed)

    # 新カラムを追加（自己参照FK）
    add_reference :handoffs, :from_stay, null: false, foreign_key: { to_table: :stays } unless column_exists?(:handoffs, :from_stay_id)
    add_reference :handoffs, :to_stay,   null: false, foreign_key: { to_table: :stays } unless column_exists?(:handoffs, :to_stay_id)

    add_column :handoffs, :checklist,    :text     unless column_exists?(:handoffs, :checklist)
    add_column :handoffs, :completed_at, :datetime unless column_exists?(:handoffs, :completed_at)

    # 予定時刻は NULL 許可にしておく（柔軟運用）
    change_column_null :handoffs, :scheduled_at, true if column_exists?(:handoffs, :scheduled_at)
  end
end
