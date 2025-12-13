class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :stay, null: false, foreign_key: true
      
      # --- 修正: users テーブルを参照するように指定 ---
      t.references :sender,   null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      # --- 修正ここまで ---

      t.text :body
      t.boolean :read, default: false # (オプション: 既読機能用)

      t.timestamps
    end
  end
end