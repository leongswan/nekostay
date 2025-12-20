class AllowNullUserInCheckins < ActiveRecord::Migration[7.0]
  def change
    # 1. もし user_id カラム自体がなければ、新しく作る（NULL許可で）
    unless column_exists?(:checkins, :user_id)
      add_reference :checkins, :user, null: true, foreign_key: true
    end

    # 2. もし user_id カラムがすでにあるなら、NULL許可に変更する
    if column_exists?(:checkins, :user_id)
      change_column_null :checkins, :user_id, true
    end
  end
end