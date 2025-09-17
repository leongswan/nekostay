class AddParentStayToStays < ActiveRecord::Migration[7.1]
  def change
    # 自己参照FK & インデックスを付けて追加
    add_reference :stays, :parent_stay, index: true, foreign_key: { to_table: :stays }
  end
end