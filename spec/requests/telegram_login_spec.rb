RSpec.describe "/login", telegram_bot: :rails do
  it "should not care about arguments" do
    expect {dispatch_message("/login a b c")}
    .to respond_with_message(/To use this bot, you need to log in with/) 
  end

  context "for an unregistered user in a group" do
    let(:user) { create(:user) }

    before(:example) do
      dispatch_message(
        "/login",
        from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        }
      )
    end

    it "should respond with the right message" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("To use this bot, you need to log in with")
      .and include("To complete your registration, open a PM with")
      .and include("or go to the website and log in with Steam there.")
      .and not_include("a) Use the button")
      .and not_include("If you want to unlink your account")
    end

    it "should have two buttons" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(2)
    end

    it "should have its first button link to the site" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In (website)\"")
      .and include(":login_url")
      .and include("/auth/telegram/callback")
    end

    it "should have its second button link to the chat" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\"Log In (message)\"")
      .and include(":url")
      .and include("\"https://t.me/")
      .and include("?start=login\"")
    end
  end

  context "for an unregistered user in a private message" do
    let(:user) { create(:user) }

    before(:example) do
      dispatch_message(
        "/login",
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
      .to  include("To use this bot, you need to log in")
      .and include("To complete your registration, you have two options")
      .and include("a) Use the button below")
      .and not_include("To complete your registration, open a PM with me")
      .and not_include("Your registration is complete")
    end

    it "should have one button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)
    end

    it "should have its button link to the site" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In (website)\"")
      .and include(":login_url")
      .and include("/auth/telegram/callback")
    end

    it "should be possible to follow up with a reply" do
      count = bot.requests[:sendMessage].count

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
        "tradeless",
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
  end

  context "for a registered user" do
    let(:user) { create(:user, :steam_registered) }

    before(:example) do
      dispatch_message(
        "/login",
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
      .to  include("Your registration is complete and you can now")
      .and not_include("To use this bot, you need to log in")
    end

    it "should have one button" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)
    end

    it "should have its button link to the site" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In (website)\"")
      .and include(":login_url")
      .and include("/auth/telegram/callback")
    end
  end
end
