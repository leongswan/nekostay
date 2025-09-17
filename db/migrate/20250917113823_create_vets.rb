class CreateVets < ActiveRecord::Migration[7.1]
  def change
    create_table :vets do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :clinic_name
      t.string :phone
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
