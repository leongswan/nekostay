# app/helpers/checkins_helper.rb
module CheckinsHelper
  def dt_label(dt)
    dt.present? ? dt.strftime("%Y-%m-%d %H:%M") : "-"
  end

  def weight_label(kg)
    # 修正: system_spec の期待値 ("4.2 kg") と合わせるため、
    # 少数点以下2桁 (format) を追加します
    kg.present? ? "#{format('%.2f', kg)} kg" : "-"
  end

  def meal_label(meal)
    m = meal || {}
    return "-" if m.blank?
    
    # 修正: 画面で確認したとおり、ヘルパー（meal_label）は
    # 「バッジ」ではなく「テキスト」を返すべきです
    [m["brand"], m["amount"]].compact.join(" / ").presence || "-"
  end

  def litter_label(litter)
    l = litter || {}
    return "-" if l.blank?
    parts = []
    parts << "固まり: #{l['clumps']}" if l['clumps'].present?
    parts << "おしっこ: #{l['pee']}"  if l['pee'].present?
    parts.presence ? parts.join(" / ") : "-"
  end

  # --- meds_badges (ピル表示) ---
  def meds_badges(meds_or_checkin)
    return "" if meds_or_checkin.nil?
    med = meds_or_checkin.is_a?(Hash) ? meds_or_checkin : (meds_or_checkin.meds || {})

    pills = []
    
    # --- 修正：CSSクラス名を ui.css に合わせる ---
    # "投与なし" -> :warn (黄/橙)
    pills << pill(t("helpers.pills.meds.none"), :warn) if med["none"]
    # "投与済" -> :ok (緑)
    pills << pill(t("helpers.pills.meds.given"), :ok) if med["given"]
    # "ワクチン" -> :ok (緑)
    pills << pill(t("helpers.pills.meds.vaccine_3rd"), :ok) if med["vaccine_3rd"]
    # --- 修正ここまで ---

    if med["name"].present? || med["dose"].present?
      name = ERB::Util.html_escape(med["name"])
      dose = ERB::Util.html_escape(med["dose"])
      pills << pill([name, dose].compact.join(" / ")) # (デフォルトの灰色)
    end

    return "-" if pills.empty?
    safe_join(pills, " ")
  end

  # --- meds_label (テキスト版) ---
  # (変更なし)
  def meds_label(meds)
    med = meds || {}
    parts = []
    parts << "投与なし" if med["none"]
    parts << "投与済" if med["given"]
    parts << "ワクチン3回目済" if med["vaccine_3rd"]
    parts << "薬剤: #{med['name']}" if med['name'].present?
    parts << "投与量: #{med['dose']}" if med['dose'].present?
    parts.present? ? parts.join(" / ") : "-"
  end

  private

  # 見た目用の汎用 pill
  def pill(text, kind = nil)
    klass = ["pill"]
    klass << "pill--#{kind}" if kind.present?
    content_tag(:span, text, class: klass.join(" "))
  end
end
