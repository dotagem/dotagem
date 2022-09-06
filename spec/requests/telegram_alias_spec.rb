RSpec.describe "/alias", telegram_bot: :rails do
  context "without any arguments" do
    it "should ask which hero you mean" do
      expect { dispatch_message("/alias") }
      .to  respond_with_message(/Which hero do you want aliases for?/)
      .and respond_with_message(/\"\/alias hero name\"/)
    end
  end

  context "with invalid arguments" do
    it "should say it can't find that hero" do
      expect { dispatch_message("/alias sdfjsdfkjsdjklfs") }
      .to respond_with_message(/I don't understand which hero/)
    end
  end

  context "with clear arguments" do
    before(:example) { dispatch_message("/alias bounty hunter") }

    it "should give a list of aliases for that hero" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("5 aliases for Bounty Hunter")
      .and include("gondar")
      .and include("bh")
      .and include("Key:")
    end

    it "should mark auto-generated aliases" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("hunter [A]")
    end

    it "should mark seeded aliases" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("gondar [S]")
    end
  end

  context "with ambiguous arguments" do
    before(:example) do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>70}}
      end

      dispatch_message("/alias vs")
    end

    it "should ask which hero you mean" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Alias list")
      .and include("Which hero did you mean by \"vs\"?")
    end

    it "should have an inline keyboard with all options" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to  include("Vengeful Spirit")
      .and include("Void Spirit")
    end

    it "should give the correct list after picking a hero" do
      dispatch(callback_query: {
        data: "alias_list:126", message: {message_id: 70, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageText].last[:text])
      .to  include("Void Spirit")
      .and include("void")
      .and not_include("venge")
      .and not_include("vengeful")
      .and not_include("Vengeful Spirit")
    end
  end
end
