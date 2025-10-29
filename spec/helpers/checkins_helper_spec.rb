require "rails_helper"

RSpec.describe CheckinsHelper, type: :helper do
  describe "#meds_badges" do
    it "none:true をバッジ表示" do
      html = helper.meds_badges({ "none" => true })
      node = Capybara.string(html)
      expect(node).to have_css("span.pill.pill--cancelled", text: "投与なし")
    end

    it "given:true をバッジ表示" do
      html = helper.meds_badges({ "given" => true })
      node = Capybara.string(html)
      expect(node).to have_css("span.pill.pill--active", text: "投与済")
    end

    it "vaccine_3rd:true をバッジ表示" do
      html = helper.meds_badges({ "vaccine_3rd" => true })
      node = Capybara.string(html)
      expect(node).to have_css("span.pill.pill--active", text: "ワクチン3回目済")
    end

    it "name/dose を1つのピルで表示" do
      html = helper.meds_badges({ "name" => "抗生剤", "dose" => "1錠" })
      node = Capybara.string(html)
      expect(node).to have_css("span.pill", text: "抗生剤 / 1錠")
    end

    it "空なら '-' を返す" do
      html = helper.meds_badges({})
      expect(html).to eq("-")
    end
  end
end
