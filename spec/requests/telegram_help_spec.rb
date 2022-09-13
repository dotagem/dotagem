RSpec.describe "/help", telegram_bot: :rails do
  it "should respond with help text" do
    expect {dispatch_message("/help")}
    .to respond_with_message(/Click the buttons below for the help page/)
  end

  it "should respond with two buttons" do
    dispatch_message("/help")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(2)
  end

  context "button" do
    before(:example) do
      dispatch_message("/help")
    end

    it "number one should lead to the help page" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Help\"")
      .and include("/help\"")
    end

    it "number two should lead to the commands page" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include("\"Commands\"")
      .and include("/commands\"")
    end
  end

  it "should not care about arguments" do
    expect {dispatch_message("/help a b c")}
    .to respond_with_message(/Click the buttons below for the help page/) 
  end
end
