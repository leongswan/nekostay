class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def show
    pdf = Prawn::Document.new
    
    # --- フォント設定 ---
    font_path = Rails.root.join("app/assets/fonts/ipaexg.ttf")
    
    if File.exist?(font_path)
      pdf.font_families.update("JapaneseFont" => {
        normal: font_path,
        bold: font_path
      })
      pdf.font "JapaneseFont"
    end
    # ------------------

    # 1. タイトル
    pdf.font_size 20
    pdf.text "ペットシッター業務委託契約書", align: :center
    pdf.move_down 30

    # 2. 契約IDと日付
    pdf.font_size 12
    pdf.text "契約ID: ##{@stay.id}"
    # 日付を "2025年12月13日" の形式に
    pdf.text "作成日: #{Date.today.strftime('%Y年%m月%d日')}"
    pdf.move_down 20

    # 3. 当事者情報
    pdf.text "【当事者】", style: :bold
    pdf.move_down 5

      owner_name = @stay.owner.try(:name).presence || @stay.owner.email
      sitter_name = @stay.sitter&.try(:name).presence || @stay.sitter&.email || "未定"
    data = [
      ["役割", "氏名", "メールアドレス"],
      ["甲 (飼い主)", owner_name, @stay.owner.email],
      ["乙 (シッター)", sitter_name, @stay.sitter&.email || "-"]
    ]
    
    # テーブル設定
    pdf.table(data, header: true, width: pdf.bounds.width) do
      cells.padding = 8
      cells.borders = [:bottom]
      cells.border_width = 0.5
      row(0).font_style = :bold
      # テーブル内でも日本語フォントを適用
      cells.font = "JapaneseFont" if File.exist?(font_path)
    end
    pdf.move_down 30

    # 4. 業務内容
    pdf.text "【業務内容】", style: :bold
    pdf.move_down 10
    
    pdf.text "期間:", style: :bold
    pdf.text "#{@stay.start_on.strftime('%Y年%m月%d日')} 〜 #{@stay.end_on.strftime('%Y年%m月%d日')}"
    pdf.move_down 10

    pdf.text "対象ペット:", style: :bold
    pdf.text "#{@stay.pet&.name || '未登録'}"
    pdf.move_down 10

    pdf.text "場所:", style: :bold
    # "owner_home" などを "飼い主の自宅" に変換
    place_text = I18n.t(@stay.place, scope: 'enums.stay.place', default: "未設定")
    pdf.text "#{place_text}"
    pdf.move_down 40

    # 5. 署名欄
    pdf.text "【署名】", style: :bold
    pdf.move_down 5
    pdf.text "本契約の成立を証するため、本書を作成し署名する。", size: 10
    pdf.move_down 40

    # 署名線を描画
    y_position = pdf.cursor
    pdf.stroke_horizontal_line 0, 200, at: y_position
    pdf.stroke_horizontal_line 300, 500, at: y_position
    pdf.move_down 5
    
    # 署名ラベル
    pdf.text_box "甲 (飼い主) 署名", at: [0, y_position - 5], width: 200, align: :center, size: 10
    pdf.text_box "乙 (シッター) 署名", at: [300, y_position - 5], width: 200, align: :center, size: 10

    # PDF出力
    send_data pdf.render,
              filename: "contract_#{@stay.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
    unless @stay.owner_id == current_user.id || @stay.sitter_id == current_user.id
      redirect_to root_path, alert: "権限がありません。"
    end
  end
end