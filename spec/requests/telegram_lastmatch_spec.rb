RSpec.describe "/lastmatch", telegram_bot: :rails do
  before(:example) do
    allow_any_instance_of(User).to receive(:matches) do
      [
        build(:list_match, match_id: 147258369)
      ]
    end
  end

  let(:user) { create(:user, :steam_registered) }

  context "from an unregistered account" do
    it "should say you need to register" do
      expect{ dispatch_message("/lastmatch") }
      .to respond_with_message(/You need to register before you can use/)
    end
  end

  context "from an incomplete account" do
    it "should say you need to complete your registration" do
      user = create(:user)

      expect { dispatch_message("/lastmatch", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }) }
      .to respond_with_message(/You need to complete your registration/)
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
    it "should say that user can't be found" do
      expect{ dispatch_message("/lastmatch 999999") }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "mentioning an incomplete account" do
    it "should tell that user they are not registered" do
      user2 = create(:user)

      expect { dispatch_message(
        "/lastmatch #{user2.telegram_username}",
        from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }
      ) }
      .to respond_with_message(/That user has not completed their registration/)
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
  end
end
