class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    # ★★★ すでにテーブルがある場合はスキップする条件を追加 ★★★
    unless table_exists?(:addresses)
      create_table :addresses do |t|
        t.string :postal_code, null: false
        t.string :prefecture,  null: false
        t.string :city,        null: false
        t.string :line1,       null: false
        t.string :line2

        t.timestamps
      end
    end
    # ★★★ ここまで ★★★
  end
end