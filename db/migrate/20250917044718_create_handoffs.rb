class CreateHandoffs < ActiveRecord::Migration[7.1]
  def change
    create_table :handoffs do |t|
      t.references :stay, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.boolean :completed

      t.timestamps
    end
  end
end
