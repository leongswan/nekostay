class StaySplitter
  MAX_DAYS = 14

  def initialize(stay)
    @stay = stay
  end

  # 分割結果を返す
  def split
    periods = []
    current_start = @stay.start_date

    while current_start <= @stay.end_date
      current_end = [current_start + (MAX_DAYS - 1).days, @stay.end_date].min
      periods << { pet_name: @stay.pet_name, start_date: current_start, end_date: current_end }
      current_start = current_end + 1.day
    end

    periods
  end

  # DBに保存する場合
  def save_splits!
    split.each do |period|
      Stay.create!(
        user: @stay.user,
        pet_name: period[:pet_name],
        start_date: period[:start_date],
        end_date: period[:end_date],
        notes: @stay.notes
      )
    end
  end
end