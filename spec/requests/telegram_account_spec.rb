RSpec.describe "/account", telegram_bot: :rails do
  before(:example) do
    dispatch_message("/account")
  end

  it "should respond with the right message" do
    expect(bot.requests[:sendMessage].last[:text])
    .to  include("To connect, disconnect or delete your account")
    .and include("use the button below or go to")
    .and include("and log in.")
  end

  it "should have a single button" do
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)
  end

  it "should allow logging in through the button" do
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Log In\"")
    .and include("/auth/telegram/callback\"")
  end
end
