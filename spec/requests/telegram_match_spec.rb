RSpec.describe "/match", telegram_bot: :rails do
  before(:example) do
    allow(Match).to receive(:from_api) do
      build(:match)
    end
  end

  let(:user) { create(:user, :steam_registered) }

  context "with no arguments" do
    it "should tell you to respond with a match id" do
      dispatch_message("/match")

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("You need to specify a match ID")
      .and not_include("Match")
    end
  end

  context "with invalid arguments" do
    it "should tell you to respond with a match id" do
      dispatch_message("/match sdfksfdjk")

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("You need to specify a match ID")
      .and not_include("Match")
    end
  end

  context "with too many arguments" do
    it "should tell you to respond with a match id" do
      dispatch_message("/match 132456 asdf")

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("You need to specify a match ID")
      .and not_include("Match")
    end
  end

  context "with valid arguments" do
    it "should respond with a valid match message" do
      expect { dispatch_message("/match 123456", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }) }
      .to  respond_with_message(/Match/)
      .and respond_with_message(/40 - 20/)
      .and respond_with_message(/Radiant victory in 30 minutes/)
      .and respond_with_message(/All Draft, Normal, US East/)
    end

    it "should fill in known players correctly" do
      user2 = create(:user, :steam_registered, steam_id: 7890)
      user3 = create(:user, :steam_registered, steam_id: 7891)

      players = build_list(:match_player, 8)
      players << build(:match_player, account_id: 7890, hero_id: 7)
      players << build(:match_player, account_id: 7891, hero_id: 137)

      allow(Match).to receive(:from_api) do
        build(:match, match_id: 123456, players: players)
      end

      dispatch_message("/match 123456")
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("#{user2.telegram_username} as Earthshaker")
      .and include("#{user3.telegram_username} as Primal Beast")
      .and not_include(user.telegram_username)
    end

    it "should not fill in unregistered users" do
      user2 = create(:user)
      dispatch_message("/match 123456")
      expect(bot.requests[:sendMessage].last[:text])
      .to  not_include(user2.telegram_username)
      .and not_include(user2.telegram_name)
    end

    it "should give a button to OpenDota" do
      allow(Match).to receive(:from_api) do
        build(:match, match_id: 12345)
      end

      dispatch_message("/match 12345", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to  include("Match details on OpenDota")
      .and include("https://opendota.com/matches/12345")
    end
  end
end
