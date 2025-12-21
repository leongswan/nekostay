FactoryBot.define do
  factory :message do
    body { "MyText" }
    stay { nil }
    user { nil }
  end
end
