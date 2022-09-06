FactoryBot.define do
  factory :match do
    sequence(:match_id) { |n| n + 6100000000 }
    duration { 1800 }
    start_time { 1.hour.ago.to_i }
    radiant_win { true }
    radiant_score { 40 }
    dire_score { 20 }
    players { build_list(:match_player, 5) +
              build_list(:match_player, 5, :dire) }
    lobby_type { 0 }
    game_mode { 22 }
    region { 2 }
    version { nil }
    patch { 50 }
  end

  factory :match_player do
    player_slot { 1 }
    account_id  { nil }
    kills { 10 }
    deaths { 4 }
    assists { 8 }
    hero_damage { 10000 }
    hero_healing { 50 }
    last_hits { 100 }
    denies { 9 }
    tower_damage { 0 }
    gold { 27000 }
    gold_per_min { 900 }
    xp_per_min { 400 }
    level { 21 }
    hero_id { 1 }
    leaver_status { 0 }

    trait :dire do
      player_slot { 128 }
    end
  end
end
