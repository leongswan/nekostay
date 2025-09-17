class CreateContracts < ActiveRecord::Migration[7.1]
  def change
    create_table :contracts do |t|
      t.references :stay, null: false, foreign_key: true
      t.string :pdf_file
      t.datetime :agreed_at

      t.timestamps
    end
  end
end
