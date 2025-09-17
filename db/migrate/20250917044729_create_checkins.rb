class CreateCheckins < ActiveRecord::Migration[7.1]
  def change
    create_table :checkins do |t|
      t.references :stay, null: false, foreign_key: true
      t.datetime :checked_at
      t.decimal :weight
      t.string :mood
      t.text :notes

      t.timestamps
    end
  end
end
