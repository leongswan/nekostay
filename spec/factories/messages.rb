FactoryBot.define do
  factory :message do
    stay { nil }
    sender { nil }
    receiver { nil }
    body { "MyText" }
  end
end
