# spec/helpers/meds_helper_spec.rb
require 'rails_helper'

RSpec.describe MedsHelper, type: :helper do
  describe "#meds_badges(meds)" do

    # ヘルパーメソッド内で I18n.t ("helpers.pills.meds.none") などを
    # 呼び出していることを想定し、ロケールを :ja に固定します。
    before { I18n.locale = :ja }

    context "meds が nil の場合" do
      it "nil または空の文字列を返す" do
        expect(helper.meds_badges(nil)).to be_nil
      end
    end

    context "meds が空のハッシュ {} の場合" do
      it "nil または空の文字列を返す" do
        expect(helper.meds_badges({})).to be_nil
      end
    end

    context "「投与なし」の場合" do
      let(:meds) { { "none" => true } }

      it "「投与なし」のバッジを表示する" do
        html = helper.meds_badges(meds)
        # 実際のヘルパーが ja.yml を参照していることを期待
        expect(html).to include(I18n.t("helpers.pills.meds.none"))
        # CSSクラスも検証すると、より堅牢
        expect(html).to include('badge--gray') # (※CSSクラスは実装に合わせてください)
      end
    end

    context "「投与済」の場合" do
      let(:meds) { { "given" => true } }

      it "「投与済」のバッジを表示する" do
        html = helper.meds_badges(meds)
        expect(html).to include(I18n.t("helpers.pills.meds.given"))
        expect(html).to include('badge--green') # (※CSSクラスは実装に合わせてください)
      end
    end

    context "「ワクチン3回目済」の場合" do
      let(:meds) { { "vaccine_3rd" => true } }

      it "「ワクチン3回目済」のバッジを表示する" do
        html = helper.meds_badges(meds)
        expect(html).to include(I18n.t("helpers.pills.meds.vaccine_3rd"))
        expect(html).to include('badge--blue') # (※CSSクラスは実装に合わせてください)
      end
    end

    context "薬剤名と投与量がある場合" do
      let(:meds) { { "name" => "抗生剤", "dose" => "1錠" } }

      it "薬剤名と投与量を表示する" do
        html = helper.meds_badges(meds)
        expect(html).to include("抗生剤 (1錠)")
        expect(html).to include('badge--pill') # (※CSSクラスは実装に合わせてください)
      end
    end

    context "薬剤名のみの場合" do
      let(:meds) { { "name" => "サプリ" } }

      it "薬剤名のみ表示する" do
        html = helper.meds_badges(meds)
        expect(html).to include("サプリ")
        expect(html).not_to include("()") # 投与量がなくても () が表示されないこと
      end
    end

    context "「投与なし」と「ワクチン」が共存する場合" do
      # checkins_controller のロジックにより "given" や "name" は "none" と共存しないはずだが、
      # "vaccine_3rd" は共存しうる、と spec/system/checkins_spec.rb で定義されていたため
      let(:meds) { { "none" => true, "vaccine_3rd" => true } }

      it "「投与なし」と「ワクチン」の両方を表示する" do
        html = helper.meds_badges(meds)
        expect(html).to include(I18n.t("helpers.pills.meds.none"))
        expect(html).to include(I18n.t("helpers.pills.meds.vaccine_3rd"))
      end
    end

    context "全指定（フルパターン）の場合" do
      # ("none" 以外がすべて指定されたパターン)
      let(:meds) { 
        { 
          "given" => true, 
          "vaccine_3rd" => true, 
          "name" => "ビタミン剤", 
          "dose" => "半錠" 
        } 
      }

      it "「投与済」「ワクチン」「薬剤名(投与量)」のすべてを表示する" do
        html = helper.meds_badges(meds)
        expect(html).to include(I18n.t("helpers.pills.meds.given"))
        expect(html).to include(I18n.t("helpers.pills.meds.vaccine_3rd"))
        expect(html).to include("ビタミン剤 (半錠)")
      end
    end

  end
end