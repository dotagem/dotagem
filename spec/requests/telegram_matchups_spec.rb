RSpec.describe "/matchups", telegram_bot: :rails do
  before(:example) do
    allow_any_instance_of(OpendotaHeroes).to receive(:matchups) {
      # 22 item list
      [{"hero_id"=>16, "games_played"=>232, "wins"=>125},  # Sand King (highest games)
        {"hero_id"=>94, "games_played"=>208, "wins"=>111}, # Medusa
        {"hero_id"=>121, "games_played"=>159, "wins"=>87}, # Grimstroke
        {"hero_id"=>129, "games_played"=>154, "wins"=>69}, # Mars
        {"hero_id"=>17, "games_played"=>149, "wins"=>70},  # Storm Spirit
        {"hero_id"=>101, "games_played"=>126, "wins"=>67}, # Skywrath Mage
        {"hero_id"=>3, "games_played"=>102, "wins"=>42},   # Bane
        {"hero_id"=>86, "games_played"=>102, "wins"=>56},  # Rubick
        {"hero_id"=>43, "games_played"=>101, "wins"=>51},  # Death Prophet
        {"hero_id"=>64, "games_played"=>100, "wins"=>46},  # Jakiro
        {"hero_id"=>39, "games_played"=>98, "wins"=>57},   # Queen of Pain
        {"hero_id"=>106, "games_played"=>97, "wins"=>44},  # Ember Spirit
        {"hero_id"=>128, "games_played"=>91, "wins"=>44},  # Snapfire
        {"hero_id"=>84, "games_played"=>89, "wins"=>53},   # Ogre Magi (highest WR/WS)
        {"hero_id"=>23, "games_played"=>88, "wins"=>49},   # Kunkka
        {"hero_id"=>13, "games_played"=>88, "wins"=>45},   # Puck
        {"hero_id"=>19, "games_played"=>87, "wins"=>45},   # Tiny
        {"hero_id"=>126, "games_played"=>86, "wins"=>49},  # Void Spirit
        {"hero_id"=>123, "games_played"=>84, "wins"=>37},  # Hoodwink
        {"hero_id"=>45, "games_played"=>83, "wins"=>41},   # Pugna
        {"hero_id"=>104, "games_played"=>82, "wins"=>38},  # Legion Commander
        {"hero_id"=>42, "games_played"=>81, "wins"=>35}]   # Wraith King
    }
  end

  context "with no arguments" do
    it 'should tell to specify a hero' do
      expect { dispatch_message("/matchups") }
      .to respond_with_message(/Which hero do you want matchups for?/)
    end
  end

  context "with an invalid hero name" do
    it "should say that hero can't be found" do
      expect { dispatch_message("/matchups dsflkjsdfjksdfd") }
      .to respond_with_message(/I don't understand which hero you mean/)
    end
  end

  context "with a clear hero name" do
    it "should respond with the right message" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1000}}
      end

      expect { dispatch_message("/matchups anti-mage") }
      .to  respond_with_message(/Matchups/)
      .and respond_with_message(/Anti-Mage/)
      .and respond_with_message(/Sorted by Wilson score/)
    end

    it "should return a list of heroes" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1001}}
      end

      dispatch_message("/matchups weaver")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(6)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include("score")
      .and include("games")
    end

    it "should sort by wilson score" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1002}}
      end

      dispatch_message("/matchups phoenix")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("Ogre Magi")
    end
  end

  context "with an unclear alias" do
    it "should ask which hero you mean" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1003}}
      end

      dispatch_message("/matchups vs")

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Matchups")
      .and include("Which hero did you mean by")
      .and include("vs")
    end

    it "should have the right buttons" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1004}}
      end

      dispatch_message("/matchups vs")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(2)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("Vengeful Spirit")
      .and include("matchups:20")
    end

    it "should show the list after picking the correct hero" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1005}}
      end

      dispatch_message("/matchups vs")

      dispatch(callback_query: {
        data: "matchups:20", message: {message_id: 1005, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageText].last[:text])
      .to  include("Matchups")
      .and include("Vengeful Spirit")
      .and include("Wilson score")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].count)
      .to eq(6)

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("Ogre Magi")
    end
  end

  context "pagination" do
    before(:example) do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>1006}}
      end

      dispatch_message("/matchups necrophos")
    end

    it "should have the right buttons on the first page" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.count)
      .to eq(3)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\">\"")
      .and include("\">>|\"")
      .and include("\"1 / 5\"")
      .and include("\"nothing:0\"")
      .and include("\"pagination:2\"")
      .and include("\"pagination:5\"")
    end

    it "should have the right buttons on the second page" do
      dispatch(callback_query: {
        data: "pagination:2", message: {message_id: 1006, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.count)
      .to eq(4)

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\">\"")
      .and include("\">>|\"")
      .and include("\"2 / 5\"")
      .and include("\"<\"")
      .and include("\"nothing:0\"")
      .and include("\"pagination:1\"")
      .and include("\"pagination:3\"")
      .and include("\"pagination:5\"")
    end

    it "should have the right buttons on the third page" do
      dispatch(callback_query: {
        data: "pagination:3", message: {message_id: 1006, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.count)
      .to eq(5)

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\">\"")
      .and include("\">>|\"")
      .and include("\"3 / 5\"")
      .and include("\"<\"")
      .and include("\"|<<\"")
      .and include("\"nothing:0\"")
      .and include("\"pagination:1\"")
      .and include("\"pagination:2\"")
      .and include("\"pagination:4\"")
      .and include("\"pagination:5\"")
    end

    it "should have the right buttons on the second to last page" do
      dispatch(callback_query: {
        data: "pagination:4", message: {message_id: 1006, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.count)
      .to eq(4)

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\">\"")
      .and include("\"4 / 5\"")
      .and include("\"<\"")
      .and include("\"|<<\"")
      .and include("\"nothing:0\"")
      .and include("\"pagination:1\"")
      .and include("\"pagination:3\"")
      .and include("\"pagination:5\"")
    end

    it "should have the right buttons on the last page" do
      dispatch(callback_query: {
        data: "pagination:5", message: {message_id: 1006, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.count)
      .to eq(3)

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\"5 / 5\"")
      .and include("\"<\"")
      .and include("\"|<<\"")
      .and include("\"nothing:0\"")
      .and include("\"pagination:1\"")
      .and include("\"pagination:4\"")
    end
  end
end
