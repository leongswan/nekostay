# app/helpers/stays_helper.rb
module StaysHelper
  def status_badge(stay)
    key = stay.status.to_s

    text =
      case key
      when "draft"     then "下書き"
      when "active"    then "滞在中"
      when "completed" then "完了"
      when "cancelled" then "キャンセル"
      else key
      end

    klass =
      case key
      when "draft"     then "pill--draft"
      when "active"    then "pill--active"
      when "completed" then "pill--completed"
      when "cancelled" then "pill--cancelled"
      else "pill" # 予備
      end

    content_tag(:span, text, class: "pill #{klass}")
  end
end

