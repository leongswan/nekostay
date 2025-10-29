FactoryBot.define do
  factory :pet do
    association :user
    name { "Mimi" }
    breed { "Mixed" }
    sex { "female" }
  end
end
