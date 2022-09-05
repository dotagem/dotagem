RSpec.describe "/login", telegram_bot: :rails do
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
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to include("Log In")
    end
  end

  context "as an account without steam registration" do
    before(:example) do
      @user = create(:user)
    end

    it 'should say to complete your registration' do
      expect {dispatch_message("/login", from: {id: @user.telegram_id})}
      .to respond_with_message(/To complete your registration, /)
    end

    it "should have an inline keyboard" do
      dispatch_message("/login", from: {id: @user.telegram_id})
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
      .to be_present
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to include("Log In")
    end
  end
  
  context "as a fully registered account" do
    before(:example) do
      @user = create(:user, :steam_registered)
    end

    it 'should say you are registered' do
      expect {dispatch_message("/login", from: {id: @user.telegram_id})}
      .to respond_with_message(/Your registration is complete/)
    end

    it 'should not affect message for other users' do
      expect {dispatch_message("/login")}
      .to respond_with_message(/To complete your registration, /)
    end

    it "should have an inline keyboard" do
      dispatch_message("/login", from: {id: @user.telegram_id})
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
      .to be_present
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to include("Log In")
    end
  end
end
