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
      .and include("b) Send a command with a link to your Steam profile")
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
end
