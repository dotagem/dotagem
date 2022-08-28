RSpec.describe TelegramUsersController, telegram_bot: :rails do
  describe "#login!" do
    context "as a new account" do
      it 'should say to complete your registration' do
        expect {dispatch_command(:login).to respond_with_message(/To complete your registration, /)}
      end
    end
    
    # context "as a fully registered account" do
    #   it 'should say you are registered' do
        
    #   end
    # end
  end
end
