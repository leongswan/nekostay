class EvolveStaysForV1 < ActiveRecord::Migration[7.1]
  def change
    # 参照カラム（存在しなければ追加）
    add_reference_if_absent :stays, :pet
    add_reference_if_absent :stays, :owner,  to_table: :users
    add_reference_if_absent :stays, :sitter, to_table: :users

    # 外部キー（存在しなければ追加）
    add_fk_if_absent :stays, :pets
    add_fk_if_absent :stays, :users, column: :owner_id
    add_fk_if_absent :stays, :users, column: :sitter_id

    # 列（存在しなければ追加）
    add_column :stays, :place,    :string  unless column_exists?(:stays, :place)
    add_column :stays, :status,   :string, default: "draft", null: false unless column_exists?(:stays, :status)
    add_column :stays, :start_on, :date    unless column_exists?(:stays, :start_on)
    add_column :stays, :end_on,   :date    unless column_exists?(:stays, :end_on)

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE stays
             SET owner_id = COALESCE(owner_id, user_id),
                 start_on = COALESCE(start_on, start_date),
                 end_on   = COALESCE(end_on,   end_date)
        SQL
        change_column_null :stays, :start_on, false if column_exists?(:stays, :start_on)
        change_column_null :stays, :end_on,   false if column_exists?(:stays, :end_on)
      end
    end
  end

  private

  def add_reference_if_absent(table, ref, to_table: nil)
    col = :"#{ref}_id"
    return if column_exists?(table, col)
    add_reference table, ref, index: true
    add_fk_if_absent table, (to_table || ref.to_s.pluralize.to_sym), column: col
  end

  def add_fk_if_absent(from_table, to_table, column: nil)
    column ||= :"#{to_table.to_s.singularize}_id"
    # 名前を固定しておくと再実行時の判定が安定
    fk_name = "fk_#{from_table}_#{column}"
    return if foreign_key_exists?(from_table, to_table, column: column, name: fk_name)
    add_foreign_key from_table, to_table, column: column, name: fk_name
  end
end