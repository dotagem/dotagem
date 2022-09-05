RSpec.describe "/help", telegram_bot: :rails do
  it "should respond with help text" do
    expect {dispatch_message("/help")}
    .to respond_with_message(/For a list of commands/)
  end

  it "should not care about arguments" do
    expect {dispatch_message("/help a b c")}
    .to respond_with_message(/For a list of commands/) 
  end
end
