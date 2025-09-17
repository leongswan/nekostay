class CreateMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :media do |t|
      t.references :attachable, polymorphic: true, null: false
      t.string :file

      t.timestamps
    end
  end
end
