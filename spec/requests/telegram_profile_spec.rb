RSpec.describe "/profile", telegram_bot: :rails do
  let(:user) { create(:user, :steam_registered) }
  context "as a registered user" do
    it "should respond with their steam url" do
      dispatch_message("/profile", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })
      expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
    end
  end

  context "as an unregistered user" do
    before(:example) do
      dispatch_message("/profile")
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
      dispatch_message("/profile", from: {
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

  context "mentioning an unknown user" do
    it "should say it doesn't know that user" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>120}}
      end

      expect { dispatch_message("/profile asdfsf", from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      }) }
      .to  respond_with_message(/I don't know that user, sorry!/)
      .and respond_with_message(/They may not be registered yet./)
    end
  end
  
  context "mentioning an incomplete user" do
    it "should say that user needs to complete their registration" do
      user2 = create(:user)
      expect { dispatch_message(
        "/profile #{user2.telegram_username}", from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        }
      ) }
      .to  respond_with_message(/That user has not signed in/)
      .and respond_with_message(/Once they sign in, their data will become available/)
    end
  end

  context "mentioning a registered user" do
    it "should respond with that user's steam link" do
      dispatch_message("/profile #{user.telegram_username}")
      expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
    end

    it "should not respond with the caller's steam link" do
      user2 = create(:user, :steam_registered)
      dispatch_message("/profile #{user2.telegram_username}", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })
      expect(bot.requests[:sendMessage].last[:text]).not_to include(user.steam_url)
    end
  end

  context "with invalid arguments" do
    it "should say it doesn't know that user" do
      dispatch_message("/profile asdsfgflkdg wehjkr", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          })
      expect(bot.requests[:sendMessage].last[:text])
      .to include("I don't know that user, sorry!")
    end
  end
end
