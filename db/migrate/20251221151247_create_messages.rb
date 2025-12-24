class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    # ★★★ unless table_exists?(:messages) を追加 ★★★
    unless table_exists?(:messages)
      create_table :messages do |t|
        t.references :stay, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.text :body

        t.timestamps
      end
    end
    # ★★★ ここまで ★★★
  end
end
