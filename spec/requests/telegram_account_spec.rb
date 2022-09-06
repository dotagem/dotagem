RSpec.describe "/account", telegram_bot: :rails do
  it "should tell you to go to the website" do
    expect {dispatch_command :account}
    .to respond_with_message(/To connect, disconnect or delete your account/)
  end

  it "should have an inline keyboard" do
    dispatch_message("/account")
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard])
    .to be_present
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
    .to include("Log In")
  end
end
