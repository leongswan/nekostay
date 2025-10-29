FactoryBot.define do
  factory :stay do
    association :owner, factory: :user
    association :pet
    start_on { Date.today }
    end_on   { Date.today + 7 }
    place { :owner_home }   # ✅ enum に存在する値に修正
    status { :draft }
  end
end

