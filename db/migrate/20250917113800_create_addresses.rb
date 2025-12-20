class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :postal_code, null: false
      t.string :prefecture,  null: false
      t.string :city,        null: false
      t.string :line1,       null: false
      t.string :line2

      t.timestamps
    end
  end
end