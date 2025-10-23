# app/helpers/stays_helper.rb
module StaysHelper
  def status_badge(stay)
    key = stay.status.to_s

    # --- i18n対応: config/locales/ja.yml の enums.stay.status.xxx を参照
    text = I18n.t("enums.stay.status.#{key}", default: key)

    # --- ステータスごとのスタイル
    klass =
      case key
      when "draft"     then "pill--draft"
      when "active"    then "pill--active"
      when "completed" then "pill--completed"
      when "cancelled" then "pill--cancelled"
      else "pill"
      end

    content_tag(:span, text, class: "pill #{klass}")
  end
end


