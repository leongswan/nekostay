class CreateStays < ActiveRecord::Migration[7.1]
  def change
    create_table :stays do |t|
      t.references :user, null: false, foreign_key: true
      t.string :pet_name
      t.date :start_date
      t.date :end_date
      t.text :notes

      t.timestamps
    end
  end
end
