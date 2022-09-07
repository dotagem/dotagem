FactoryBot.define do
  factory :list_match do
    sequence(:match_id) { |n| 10000 - n }
    player_slot { 1 }
    radiant_win { true }
    duration { 1800 }
    lobby_type { 0 }
    game_mode { 22 }
    hero_id { 1 }
    start_time { 1.hour.ago.to_i }
    kills { 10 }
    deaths { 3 }
    assists { 5 }
    average_rank { 51 }
    leaver_status { 0 }
    party_size { 1 }
    gold_per_min { 500 }
    xp_per_min { 600 }
    hero_damage { 6000 }
    tower_damage { 2000 }
    hero_healing { 90 }
    last_hits { 90 }
    denies { 10 }
    version { nil }
    region { 2 }

    trait :dire do
      player_slot { 128 }
    end
  end
end
