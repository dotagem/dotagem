FactoryBot.define do
  factory :user do
    sequence(:telegram_name) { |n| "User #{n}" }
    sequence(:telegram_id) { |n| 124 + n }
    sequence(:telegram_username) { |n| "user_#{n}" }
  
    trait :steam_registered do
      sequence(:steam_id) { |n| n + 17000000 }
      sequence(:steam_id64) { |n| n + 76000000000000000 }
      steam_url { "https://steamcommunity.com/id/#{:steam_id64}" }
    end
  end
end
