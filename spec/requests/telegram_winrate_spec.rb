RSpec.describe "/winrate", telegram_bot: :rails do
  context "from an unregistered user" do
    it "should say that user can't be found" do
      expect { dispatch_message("/winrate", from: {id: 99999}) }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "from an incomplete user" do
    it "should tell the user that they are not registered" do
      user = create(:user)

      expect { dispatch_message("/winrate", from: {id: user.telegram_id}) }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "mentioning an unregistered user" do
    it "should say that user can't be found" do
      expect { dispatch_message("/winrate sdlkjfjkdfjkjkdf") }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "mentioning an incomplete user" do
    it "should tell the user that they are not registered" do
      user = create(:user)

      expect { dispatch_message("/winrate #{user.telegram_username}") }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "without arguments" do
    before(:example) do
      allow_any_instance_of(User).to receive(:win_loss) {
        {"win" => 999, "lose" => 123}
      }
    end

    let(:user) { create(:user, :steam_registered) }

    it "should give a global winrate" do
      expect { dispatch_message("/winrate", from: {id: user.telegram_id}) }
      .to  respond_with_message(/Winrate for #{user.telegram_username}:/)
      .and respond_with_message(/999 wins, 123 losses/)
    end

    it "should pluralize correctly" do
      allow_any_instance_of(User).to receive(:win_loss) {
        {"win" => 1, "lose" => 1}
      }

      expect { dispatch_message("/winrate", from: {id: user.telegram_id}) }
      .to respond_with_message(/1 win, 1 loss/)
    end
  end

  context "with clear arguments" do
    before(:example) do
      allow_any_instance_of(User).to receive(:win_loss) {
        {"win" => 999, "lose" => 123}
      }
    end

    let(:user) { create(:user, :steam_registered) }

    it "should handle hero arguments correctly" do

      expect { dispatch_message(
        "/winrate weaver against razor with faceless void and spectre against dazzle",
        from: {id: user.telegram_id}
      )}
      .to  respond_with_message(/Winrate for #{user.telegram_username}:/)
      .and respond_with_message(/Playing as Weaver/)
      .and respond_with_message(/Allied heroes: Faceless Void, Spectre/)
      .and respond_with_message(/Enemy heroes: Razor, Dazzle/)
    end

    it "should handle player arguments correctly" do
      user2 = create(:user, :steam_registered)
      user3 = create(:user, :steam_registered)
      expect { dispatch_message(
        "/winrate with #{user2.telegram_username} and #{user3.telegram_username}",
        from: {id: user.telegram_id}
      )}
      .to  respond_with_message(/Winrate for #{user.telegram_username}:/)
      .and respond_with_message(
        /With players: #{user2.telegram_username}, #{user3.telegram_username}/
      )
    end
  end

  context "with unclear aliases" do
    before(:example) do
      allow_any_instance_of(User).to receive(:win_loss) {
        {"win" => 999, "lose" => 123}
      }
    end

    let(:user) { create(:user, :steam_registered) }

    it "should ask for clarification" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>80}}
      end

      dispatch_message("/winrate void", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Winrate for #{user.telegram_username}")
      .and include("Which hero did you mean")
      .and include(">>\"void\"<<")
      .and not_include("Void Spirit")
      .and not_include("Faceless Void")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to  include("Void Spirit")
      .and include("Faceless Void")
      .and include("\"alias:41\"")
    end

    it "should ask multiple times if necessary" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>81}}
      end

      dispatch_message("/winrate void against es", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:text])
      .to include(">>\"void\"<<")

      dispatch(callback_query: {
        data: "alias:41", message: {message_id: 81, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageText].last[:text])
      .to  include("Faceless Void")
      .and not_include("\"void\"")
      .and include(">>\"es\"<<")
      .and include("Which hero did you mean")
    end

    it "should show the correct output once everything is cleared up" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>82}}
      end

      dispatch_message("/winrate void against es", from: {id: user.telegram_id})

      dispatch(callback_query: {
        data: "alias:41", message: {message_id: 82, chat: {id: 456}}
      })

      dispatch(callback_query: {
        data: "alias:7", message: {message_id: 82, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageText].last[:text])
      .to  include("Winrate for #{user.telegram_username}")
      .and include("Playing as Faceless Void")
      .and include("Enemy heroes: Earthshaker")
      .and not_include("\"void\"")
      .and not_include("\"es\"")
      .and include("999 wins, 123 losses")
    end
  end
end
