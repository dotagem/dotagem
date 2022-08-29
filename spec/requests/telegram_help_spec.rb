RSpec.describe TelegramHelpController, telegram_bot: :rails do
  describe "#help!" do
    it "should respond with help text" do
      expect {dispatch_message("/help")}
      .to respond_with_message(//)
    end

    it "should not care about arguments" do
      expect {dispatch_message("/help a b c")}
      .to respond_with_message(//) 
    end
  end

  describe "#commands!" do

  end

  describe "#start!" do

  end
end
