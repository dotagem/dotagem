RSpec.describe TelegramUsersController, telegram_bot: :rails do
  describe "#login!" do
    context "as a new account" do
      it 'should say to complete your registration' do
        expect {dispatch_message("/login")}.to respond_with_message(/To complete your registration, /)
      end
    end
    
    context "as a fully registered account" do
      before(:example) do
        u = User.create(telegram_id: 12345, telegram_username: "someone",
          steam_id: 12345, steam_id64: 1234567890, steam_nickname: "a",
          steam_url: "https://steamcommunity.com/id/me",
          telegram_name: "Someone")
      end

      it 'should say you are registered' do
        expect {dispatch_message("/login", from: {id: 12345})}.to respond_with_message(/Your registration is complete/)
      end
    end
  end
end
