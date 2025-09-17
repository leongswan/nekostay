class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :stay, null: false, foreign_key: true
      t.integer :amount_cents
      t.string :currency
      t.string :status
      t.string :provider
      t.string :charge_id

      t.timestamps
    end
    add_index :payments, :charge_id, unique: false
  end
end
