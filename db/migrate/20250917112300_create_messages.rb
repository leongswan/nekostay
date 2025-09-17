class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :stay, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, :read_at
  end
end
