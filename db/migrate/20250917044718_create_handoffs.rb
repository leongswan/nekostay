class CreateHandoffs < ActiveRecord::Migration[7.1]
  def change
    create_table :handoffs do |t|
      t.references :from_stay, null: false, foreign_key: { to_table: :stays }
      t.references :to_stay,   null: false, foreign_key: { to_table: :stays }
      t.text :checklist
      t.datetime :scheduled_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end