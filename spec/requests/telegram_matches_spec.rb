RSpec.describe "/matches", telegram_bot: :rails do
  context "from an unregistered user" do
    it "should say that user can't be found" do
      expect { dispatch_message("/matches", from: {id: 99999}) }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "from an incomplete user" do
    it "should tell the user they are not registered" do
      user = create(:user)

      expect { dispatch_message("/matches", from: {id: user.telegram_id}) }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "mentioning an unregistered user" do
    it "should say that user can't be found" do
      expect { dispatch_message("/matches lkjlkjlkjkljlkjl") }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "mentioning an incomplete user" do
    it "should say that user hasn't completed their registration" do
      user = create(:user)
      expect { dispatch_message("/matches #{user.telegram_username}") }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "without arguments" do
    let (:user) { create(:user, :steam_registered) }

    it "should return the most recent matches" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>50}}
      end
      
      allow_any_instance_of(User).to receive(:matches) {build_list(:list_match, 4)}

      expect { dispatch_message("/matches", from: {id: user.telegram_id}) }
      .to respond_with_message(/4 results/)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to match(/Anti-Mage about 1 hour ago/)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(4)
    end

    it "should paginate more than 5 results" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>51}}
      end

      allow_any_instance_of(User).to receive(:matches) {build_list(:list_match, 38)}

      expect { dispatch_message("/matches", from: {id: user.telegram_id}) }
      .to respond_with_message(/38 results/)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(6)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("1 / 8")
      .and include(">>|")
    end

    it "should not paginate less than 6 results" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>52}}
      end

      allow_any_instance_of(User).to receive(:matches) {build_list(:list_match, 5)}

      expect { dispatch_message("/matches", from: {id: user.telegram_id}) }
      .to respond_with_message(/5 results/)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(5)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.count)
      .to eq(1)
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .not_to include("1 /")
    end
  end

  context "with clear arguments" do
    let(:user) { create(:user, :steam_registered) }

    it "should handle a simple hero argument" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>53}}
      end

      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 5, hero_id: 63)
      }

      dispatch_message("/matches weaver", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Matches for #{user.telegram_username}")
      .and include("Playing as Weaver")
      .and include("5 results")
      .and not_include("Allied")
      .and not_include("Enemy")
    end

    it "should handle several hero arguments" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>54}}
      end

      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 5, hero_id: 63)
      }

      dispatch_message(
        "/matches against venomancer with spectre as weaver",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Playing as Weaver")
      .and include("5 results")
      .and include("Allied heroes: Spectre")
      .and include("Enemy heroes: Venomancer")
    end

    it "should handle multiple hero arguments on the same field" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>55}}
      end

      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 5, hero_id: 63)
      }

      dispatch_message(
        "/matches weaver with earthshaker against venomancer and spectre with mars",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Playing as Weaver")
      .and include("5 results")
      .and include("Allied heroes: Earthshaker, Mars")
      .and include("Enemy heroes: Venomancer, Spectre")
    end

    it "should handle teammate arguments" do
      user2 = create(:user, :steam_registered)

      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>56}}
      end

      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 5, hero_id: 63)
      }

      dispatch_message(
        "/matches with #{user2.telegram_username}",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("5 results")
      .and include("With players: #{user2.telegram_username}")
    end

    it "should be able to fetch matches for a different player" do
      user2 = create(:user, :steam_registered)

      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>57}}
      end

      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 5, hero_id: 63)
      }

      dispatch_message(
        "/matches #{user2.telegram_username} as weaver",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Matches for #{user2.telegram_username}")
      .and include("Playing as Weaver")
      .and include("5 results")
    end
  end

  context "with aliases" do
    let(:user) { create(:user, :steam_registered) }

    it "should ask for clarification" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>58}}
      end

      dispatch_message(
        "/matches es",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  not_include("Matches for #{user.telegram_username}")
      .and include(">>\"es\"<<")
      .and include("Which hero did you mean")
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].to_s)
      .to  include("Earthshaker")
      .and include("Ember Spirit")
      .and include("\"alias:7\"")
    end

    # it "should pick the correct hero after button press", :callback_query do
    #   expect(bot).to receive(:request).and_wrap_original do |m, *args|
    #     m.call(*args)
    #     {"ok"=>true, "result"=>{"message_id"=>59}}
    #   end

    #   dispatch_message(
    #     "/matches es",
    #     from: {id: user.telegram_id}
    #   )

    #   dispatch(callback_query: {
    #     data: "alias:7", chat: {id: 456}, message_id: 59
    #   })

    #   # expect(bot.requests.last)
    # end

  #   it "should ask multiple times if necessary" do

  #   end

  #   it "should return a list of matches once everything is clear" do

  #   end
  end
end
