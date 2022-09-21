RSpec.describe "/lastmatch", telegram_bot: :rails do
  before(:example) do
    allow_any_instance_of(User).to receive(:matches) do
      [
        build(:list_match, match_id: 147258369)
      ]
    end
  end

  let(:user) { create(:user, :steam_registered) }

  context "as an unregistered user" do
    before(:example) do
      dispatch_message("/lastmatch")
    end

    it "should say you need to register" do
      expect(bot.requests[:sendMessage].last[:text])
      .to include("You need to register before")
    end

    it "should provide a button to pm the bot" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In\"")
      .and include("https://t.me/")
      .and include(":url")
    end
  end

  context "as an incomplete user" do
    let(:user) { create(:user) }
    
    before(:example) do
      dispatch_message("/lastmatch", from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      })
    end

    it "should say that you need to register" do
      expect(bot.requests[:sendMessage].last[:text])
      .to include("You need to register before")
    end

    it "should provide a button to pm the bot" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In\"")
      .and include("https://t.me/")
      .and include(":url")
    end
  end

  context "from a valid account" do
    it "should return a valid message" do
      dispatch_message("/lastmatch", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Recent match for #{user.telegram_username}")
      .and include("Win in 30 mins")
      .and include("Avg. rank: Legend 1")
      .and include("10/3/5")
      .and include("Anti-Mage")
      .and include("1 hour ago")
    end

    it "should display the correct result" do
      allow_any_instance_of(User).to receive(:matches) do
        [
          build(:list_match, player_slot: 129)
        ]
      end

      dispatch_message("/lastmatch", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Loss in 30 mins")
    end

    it "should return a button to OpenDota" do
      dispatch_message("/lastmatch", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to  include("Match details on OpenDota")
      .and include("https://opendota.com/matches/147258369")
    end
  end

  context "mentioning an unregistered account" do
    it "should say it doesn't know that user" do
      expect{ dispatch_message("/lastmatch 999999") }
      .to  respond_with_message(/I don't know that user, sorry!/)
      .and respond_with_message(/They may not be registered yet/)
    end
  end

  context "mentioning an incomplete account" do
    it "should say that user needs to sign in with Steam" do
      user2 = create(:user)

      expect { dispatch_message(
        "/lastmatch #{user2.telegram_username}",
        from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }
      ) }
      .to  respond_with_message(/That user has not signed in with Steam yet!/)
      .and respond_with_message(/Once they sign in, their data will become available/)
    end
  end

  context "mentioning a valid account" do
    it "should display the correct user's match" do
      user2 = create(:user, :steam_registered)

      dispatch_message(
        "/lastmatch #{user2.telegram_username}",
        from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include(user2.telegram_username)
      .and not_include(user.telegram_username)
    end

    it "should not care about capitalization" do
      user2 = create(:user, :steam_registered)

      dispatch_message(
        "/lastmatch #{user2.telegram_username.upcase}",
        from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include(user2.telegram_username)
      .and not_include(user.telegram_username)
    end
  end
end
