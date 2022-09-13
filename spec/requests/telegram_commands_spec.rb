RSpec.describe "/commands", telegram_bot: :rails do
  it "should respond with help text" do
    expect {dispatch_message("/commands")}
    .to respond_with_message(/Click the button below for a list of commands/)
  end

  it "should respond with a button to the commands page" do
    dispatch_message("/commands")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Commands\"")
    .and include("/commands\"")
  end

  it "should not care about arguments" do
    expect {dispatch_message("/commands a b c")}
    .to respond_with_message(/Click the button below for a list of commands/) 
  end
end
