class CreateEmergencyContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :emergency_contacts do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.string :relation

      t.timestamps
    end
  end
end
