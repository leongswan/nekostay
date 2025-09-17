class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :stay, null: false, foreign_key: true
      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :ratee, null: false, foreign_key: { to_table: :users }
      t.integer :score
      t.text :comment

      t.timestamps
    end
  end
end
