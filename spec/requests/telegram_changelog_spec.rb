RSpec.describe "/changelog", telegram_bot: :rails do
  it "should respond with a message" do
    allow(Rails.application.credentials.telegram).to receive(:channel_id) {
      "@gemtest_updates"
    }

    dispatch_message("/changelog")

    expect(bot.requests[:sendMessage].last[:text])
    .to  not_include("No updates channel has been configured")
    .and include("notification when a new update goes live")
  end

  it "should mention there is no changelog channel if none is given" do
    allow(Rails.application.credentials.telegram).to receive(:channel_id) {
      nil
    }

    dispatch_message("/changelog")

    expect(bot.requests[:sendMessage].last[:text])
    .to  include("No updates channel has been configured")
    .and not_include("notification when a new update goes live")
  end
end
