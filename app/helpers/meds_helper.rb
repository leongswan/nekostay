# app/helpers/meds_helper.rb
module MedsHelper
  
  # meds カラム (JSON) を受け取り、HTMLのバッジを生成します
  def meds_badges(meds)
    return nil if meds.blank? # nil や {} の場合は何も返さない

    badges = []

    # 1. 薬剤名 (Name/Dose)
    # (checkins_controller のロジックにより "none" == true の時は name/dose は存在しないはず)
    if meds["name"].present?
      name = ERB::Util.html_escape(meds["name"])
      dose = ERB::Util.html_escape(meds["dose"])
      
      text = dose.present? ? "#{name} (#{dose})" : name
      
      # (※ CSSクラス 'badge--pill' は system_spec の推測です)
      badges << content_tag(:span, text, class: "badge badge--pill")
    end

    # 2. 投与済 (Given)
    if meds["given"]
      badges << content_tag(
        :span, 
        t("helpers.pills.meds.given"), 
        class: "badge badge--green" # (※ CSSクラスは実装に合わせてください)
      )
    end

    # 3. 投与なし (None)
    if meds["none"]
      badges << content_tag(
        :span, 
        t("helpers.pills.meds.none"), 
        class: "badge badge--gray" # (※ CSSクラスは実装に合わせてください)
      )
    end
    
    # 4. ワクチン (Vaccine)
    if meds["vaccine_3rd"]
      badges << content_tag(
        :span, 
        t("helpers.pills.meds.vaccine_3rd"), 
        class: "badge badge--blue" # (※ CSSクラスは実装に合わせてください)
      )
    end

    return nil if badges.empty?

    # 全てのバッジHTMLを連結して返す
    safe_join(badges, " ")
  end
end