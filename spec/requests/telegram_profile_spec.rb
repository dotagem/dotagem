RSpec.describe "/profile", telegram_bot: :rails do
  context "as a registered user" do
    it "should respond with their steam url" do
      user = create(:user, :steam_registered)
      dispatch_message("/profile", from: {id: user.telegram_id})
      expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
    end
  end

  context "as an unregistered user" do
    it "should say you need to register" do
      expect {dispatch_message("/profile")}
      .to respond_with_message(/You need to register before/)
    end
  end

  context "as an incomplete user" do
    it "should say you need to complete your registration" do
      user = create(:user)
      expect {dispatch_message("/profile", from: {id: user.telegram_id})}
      .to respond_with_message(/You need to complete your registration/)
    end
  end

  context "mentioning a registered user" do
    it "should respond with that user's steam link" do
      user = create(:user, :steam_registered)
      dispatch_message("/profile #{user.telegram_username}")
      expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
    end

    it "should not respond with the caller's steam link" do
      user  = create(:user, :steam_registered)
      user2 = create(:user, :steam_registered)
      dispatch_message("/profile #{user2.telegram_username}", from: {id: user.telegram_id})
      expect(bot.requests[:sendMessage].last[:text]).not_to include(user.steam_url)
    end
  end

  context "mentioning an unregistered user" do
    it "should say it can't find that user" do
      expect { dispatch_message("/profile asdfasdfsdf") }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "mentioning an incomplete user" do
    it "should tell the user to complete their registration" do
      user = create(:user)
      expect {dispatch_message("/profile #{user.telegram_username}")}
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "with invalid arguments" do
    it "should say it can't find that user" do
      user = create(:user, :steam_registered)
      dispatch_message("/profile asdsfgflkdg wehjkr", from: {id: user.telegram_id})
      expect(bot.requests[:sendMessage].last[:text])
      .to include("Can't find that user")
    end
  end
end
