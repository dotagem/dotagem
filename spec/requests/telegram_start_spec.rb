RSpec.describe "/start", telegram_bot: :rails do
  context "in a group chat" do
    before(:example) do
      dispatch_message("/start")
    end

    it "should include the default text" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Hello! I can fetch your Dota 2 match data")
    end

    it "should include the group chat text" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("To let me show your stats, I will need to know which")
      .and include("If you want to use my commands, you need to")
      .and include("complete your registration on the site")
      .and include("or use the other button and complete it in chat")
    end

    it "should include two buttons" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(2)
    end

    it "should link to the site with the first button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In (website)\"")
      .and include(":login_url")
      .and include("/auth/telegram/callback")
    end

    it "should link to a chat with the second button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\"Log In (message)\"")
      .and include(":url")
      .and include("\"https://t.me")
      .and include("?start=login\"")
    end
  end

  context "in a registered user's direct messages" do
    let(:user) { create(:user, :steam_registered) }

    before(:example) do
      dispatch_message(
        "/start",
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        },
        chat: {
          id: user.telegram_id,
          type: "private"
        }
      )
    end

    it "should include the default text" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Hello! I can fetch your Dota 2 match data")
    end

    it "should include the registered user text" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("You are already signed in and ready")
      .and include("If you want to edit or remove your registration")
      .and include("You can also send me a link to a Steam profile")
    end

    it "should include a single button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)
    end

    it "should link to the site with its button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In (website)\"")
      .and include(":login_url")
      .and include("/auth/telegram/callback")
    end
  end

  context "in an unregistered user's direct messages" do
    let(:user) { create(:user) }

    before(:example) do
      dispatch_message(
        "/start",
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        },
        chat: {
          id: user.telegram_id,
          type: "private"
        }
      )
    end

    it "should include the default text" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Hello! I can fetch your Dota 2 match data")
    end

    it "should include the unregistered user text" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("To let me show your stats, you have two options")
      .and include("a) Use the button below this message and log in")
      .and include("b) Send a message with a link to your Steam profile!")
    end

    it "should include a single button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)
    end

    it "should link to the site with its button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In (website)\"")
      .and include(":login_url")
      .and include("/auth/telegram/callback")
    end
  end

  context "in-chat registration" do
    let(:user) { create(:user) }

    before(:example) do
      dispatch_message(
        "/start",
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        },
        chat: {
          id: user.telegram_id,
          type: "private"
        }
      )

      allow(SteamID).to receive(:from_string) {
        SteamID::SteamID.new(63244260)
      }

      allow_any_instance_of(SteamCondenser::Community::SteamId).to receive(:nickname) {
        "Tradeless"
      }
      allow_any_instance_of(SteamCondenser::Community::SteamId).to receive(:full_avatar_url) {
        "https://avatars.akamai.steamstatic.com/8d5933942b1be8d27bae80cb472f5d027651a1ad_full.jpg"
      }

      dispatch_message(
        "63244260",
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        },
        chat: {
          id: user.telegram_id,
          type: "private"
        }
      )
    end

    it "should respond with the right message" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("https://steamcommunity.com/profiles/76561198023509988")
      .and include("If you want to register this account, press the button")
    end

    it "should have one button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)
    end

    it "should have its button lead to registering that account" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Register this account\"")
      .and include("\"register:63244260\"")
    end

    it "should allow to try again" do
      count = bot.requests[:sendMessage].count

      dispatch_message(
        "63244260",
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        },
        chat: {
          id: user.telegram_id,
          type: "private"
        }
      )

      expect(bot.requests[:sendMessage].count).to eq(count + 1)

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("https://steamcommunity.com/profiles/76561198023509988")
      .and include("If you want to register this account, press the button")
    end

    it "should change the user's registration when they press the button" do
      dispatch(callback_query: {
        data: "register:63244260",
        message: {
          message_id: 900,
          chat: {id: user.telegram_id},
        },
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        }
      })

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Your registration is now complete and you can")
      .and include("If you want to edit or remove your registration")
      .and not_include("Another account in the database had")

      db_user = User.find_by(telegram_id: user.telegram_id)
      expect(db_user.steam_id)
      .to eq(63244260)
      expect(db_user.steam_url)
      .to eq("https://steamcommunity.com/profiles/76561198023509988")
    end

    it "should override conflicting registrations" do
      user2 = create(
        :user,
        :steam_registered,
        steam_id64: 76561198023509988,
        steam_id: 63244260,
        steam_url: "https://steamcommunity.com/profiles/76561198023509988"
      )

      dispatch(callback_query: {
        data: "register:63244260",
        message: {
          message_id: 900,
          chat: {id: user.telegram_id},
        },
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        }
      })

      db_user = User.find_by(telegram_id: user2.telegram_id)
      expect(db_user.steam_id).to eq(nil)
    end

    it "should notify if a registration was removed" do
      user2 = create(
        :user,
        :steam_registered,
        steam_id64: 76561198023509988,
        steam_id: 63244260,
        steam_url: "https://steamcommunity.com/profiles/76561198023509988"
      )

      dispatch(callback_query: {
        data: "register:63244260",
        message: {
          message_id: 900,
          chat: {id: user.telegram_id},
        },
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        }
      })

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Another account in the database had this")
      .and include("their registration has been removed.")
    end
  end
end
