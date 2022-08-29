RSpec.describe TelegramUsersController, telegram_bot: :rails do
  describe "#login!" do
    it "should not care about arguments" do
      expect {dispatch_message("/login a b c")}
      .to respond_with_message(/To complete your registration/) 
    end

    context "as a new account" do
      it 'should say to complete your registration' do
        expect {dispatch_message("/login")}
        .to respond_with_message(/To complete your registration, /)
      end

      it "should have an inline keyboard" do
        dispatch_message("/login")
        expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
        .to be_present
      end
    end

    context "as an account without steam registration" do
      before(:example) do
        User.create(telegram_id: 12345, telegram_username: "someone",
          telegram_name: "Someone")
      end

      it 'should say to complete your registration' do
        expect {dispatch_message("/login", from: {id: 12345})}
        .to respond_with_message(/To complete your registration, /)
      end

      it "should have an inline keyboard" do
        dispatch_message("/login", from: {id: 12345})
        expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
        .to be_present
      end
    end
    
    context "as a fully registered account" do
      before(:example) do
        User.create(telegram_id: 12345, telegram_username: "someone",
          steam_id: 12345, steam_id64: 1234567890, steam_nickname: "a",
          steam_url: "https://steamcommunity.com/id/me",
          telegram_name: "Someone")
      end

      it 'should say you are registered' do
        expect {dispatch_message("/login", from: {id: 12345})}
        .to respond_with_message(/Your registration is complete/)
      end

      it 'should not affect message for other users' do
        expect {dispatch_message("/login")}
        .to respond_with_message(/To complete your registration, /)
      end

      it "should have an inline keyboard" do
        dispatch_message("/login")
        expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
        .to be_present
      end
    end
  end

  describe "#account!" do
    subject { -> { dispatch_command :account } }
    it "should tell you to go to the website" do
      should respond_with_message(/To connect, disconnect or delete your account/)
    end

    it "should have an inline keyboard" do
      dispatch_message("/account")
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
      .to be_present
    end
  end
end
