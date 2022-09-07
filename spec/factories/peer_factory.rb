FactoryBot.define do
  factory :peer do
    account_id do
      create(:user, :steam_registered).steam_id
    end
    last_played { 1.hour.ago.to_i }
    with_win { 50 }
    with_games { 100 }
  end
end
