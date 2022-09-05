RSpec.describe "/start", telegram_bot: :rails do
  it "should respond with help text" do
    expect {dispatch_message("/start")}
    .to respond_with_message(/Hello! I can fetch your Dota 2 match data/)
  end

  it "should not care about arguments" do
    expect {dispatch_message("/start as df sfdlkwe")}
    .to respond_with_message(/Hello! I can fetch your Dota 2 match data/)
  end
end
