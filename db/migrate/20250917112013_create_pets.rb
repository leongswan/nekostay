class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :breed
      t.string :sex
      t.date :birthdate
      t.decimal :weight
      t.boolean :spay_neuter
      t.text :vaccine_info
      t.text :medical_notes

      t.timestamps
    end
  end
end
