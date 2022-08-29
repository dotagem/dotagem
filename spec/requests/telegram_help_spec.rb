RSpec.describe TelegramHelpController, telegram_bot: :rails do
  describe "#help!" do
    it "should respond with help text" do
      expect {dispatch_message("/help")}
      .to respond_with_message(/For a list of commands/)
    end

    it "should not care about arguments" do
      expect {dispatch_message("/help a b c")}
      .to respond_with_message(/For a list of commands/) 
    end
  end

  describe "#start!" do
    it "should respond with help text" do
      expect {dispatch_message("/start")}
      .to respond_with_message(/Hello! I can fetch your Dota 2 match data/)
    end

    it "should not care about arguments" do
      expect {dispatch_message("/start as df sfdlkwe")}
      .to respond_with_message(/Hello! I can fetch your Dota 2 match data/)
    end
  end
end
