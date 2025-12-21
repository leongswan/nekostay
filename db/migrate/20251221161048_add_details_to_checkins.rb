class AddDetailsToCheckins < ActiveRecord::Migration[7.0]
  def change
    # food と mood はもう存在している（または追加済み）なので削除します
    # add_column :checkins, :food, :integer
    # add_column :checkins, :mood, :integer

    # ↓ まだ追加されていない、この2つだけを実行します
    add_column :checkins, :pee_count, :integer
    add_column :checkins, :poop_count, :integer
  end
end