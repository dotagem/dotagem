RSpec.describe "/heroes", telegram_bot: :rails do
  before(:example) do
    allow_any_instance_of(User).to receive(:heroes) do
      array = Hero.where(
        localized_name: ["Anti-Mage",    "Zeus",          "Faceless Void",
                         "Weaver",       "Invoker",       "Io",
                         "Ember Spirit", "Winter Wyvern", "Mars"]
      )

      array.each do |h|
        h.last_played = 1.day.ago.to_i
        h.games = 50
        h.win   = 25
        h.with_games = 40
        h.with_win   = 30
        h.against_games = 60
        h.against_win   = 40
      end

      # Highest alphabetically: Anti-Mage
      # Highest games: Ember Spirit
      array[6].games = 100
      array[6].win   = 50
      # Highest winrate: Zeus
      array[1].win = 45
      # Highest games with: Faceless Void
      array[2].with_games = 80
      array[2].with_win   = 60
      # Highest winrate with: Weaver
      array[3].with_win = 35
      # Highest games against: Invoker
      array[4].against_games = 120
      array[4].against_win   = 80
      # Highest winrate against: Io
      array[5].against_win = 50

      array.sort_by {|i| i.games * -1 }
    end
  end

  let(:user) { create(:user, :steam_registered) }

  context "as an unregistered user" do
    it "should say that user can't be found" do
      expect { dispatch_message("/heroes") }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "as an incomplete user" do
    it "should say that user needs to complete their registration" do
      user = create(:user)
      expect { dispatch_message("/heroes", from: {id: user.telegram_id}) }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "mentioning an unknown user" do
    it "should fall back to the current user" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>120}}
      end

      expect { dispatch_message("/heroes asdfsf", from: {id: user.telegram_id}) }
      .to respond_with_message(/Heroes for #{user.telegram_username}/)
    end
  end
  
  context "mentioning an incomplete user" do
    it "should say that user needs to complete their registration" do
      user2 = create(:user)
      expect { dispatch_message(
        "/heroes #{user2.telegram_username}", from: {id: user.telegram_id}
      ) }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "without arguments" do
    before(:example) do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>122}}
      end

      dispatch_message("/heroes", from: {id: user.telegram_id})
    end

    it "should return a valid message" do
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Heroes for #{user.telegram_username}")
    end

    it "should have the right amount of button rows" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(8)
    end

    it "should generate a valid mode row" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Mode:\"")
      .and include("\"[As]\"")
      .and include("\"change_hero_mode:with\"")
      .and include("\"change_hero_mode:against\"")
    end

    it "should generate a valid sort row" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include("\"Sort:\"")
      .and include("\"[Games]\"")
      .and include("\"change_hero_sort:win\"")
      .and include("\"change_hero_sort:alphabetical\"")
    end

    it "should generate a valid pagination row" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("\">\"")
      .and include("\"pagination:2\"")
      .and include("\"1 / 2\"")
    end

    it "should generate valid hero buttons" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].third.to_s)
      .to  include("50.0%")
      .and include("last 1 day ago")
      .and include("\"matches_hero:")
    end
  end

  context "mentioning a valid user" do
    it "should give heroes for that user" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>123}}
      end

      user2 = create(:user, :steam_registered)

      dispatch_message("/heroes #{user2.telegram_username}")

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Heroes for #{user2.telegram_username}")
      .and not_include(user.telegram_username)
    end
  end

  context "sort and mode" do
    before(:example) do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>124}}
      end

      dispatch_message("/heroes", from: {id: user.telegram_id})
    end

    it "should start by games played as" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("[As]")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[Games]")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Ember Spirit")
    end

    it "should sort by winrate played as" do
      dispatch(callback_query: {
        data: "change_hero_sort:win", message: {message_id: 124, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("[As]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[Win %]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Zeus")
    end

    it "should sort by games played with" do
      dispatch(callback_query: {
        data: "change_hero_mode:with", message: {message_id: 124, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("[With]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[Games]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Faceless Void")
    end

    it "should sort by winrate played with" do
      dispatch(callback_query: {
        data: "change_hero_mode:with", message: {message_id: 124, chat: {id: 456}}
      })

      dispatch(callback_query: {
        data: "change_hero_sort:win", message: {message_id: 124, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("[With]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[Win %]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Weaver")
    end

    it "should sort by games played against" do
      dispatch(callback_query: {
        data: "change_hero_mode:against", message: {message_id: 124, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("[Against]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[Games]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Invoker")
    end

    it "should sort by winrate played against" do
      dispatch(callback_query: {
        data: "change_hero_mode:against", message: {message_id: 124, chat: {id: 456}}
      })

      dispatch(callback_query: {
        data: "change_hero_sort:win", message: {message_id: 124, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to include("[Against]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[Win %]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Io")
    end

    it "should sort alphabetically" do
      dispatch(callback_query: {
        data: "change_hero_sort:alphabetical", message: {message_id: 124, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to include("[A-Z]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].third.to_s)
      .to include("Anti-Mage")
    end
  end

  context "pagination" do
    before(:example) do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>125}}
      end

      allow_any_instance_of(User).to receive(:heroes) do
        array = Hero.take(24)

        array.each do |h|
          h.last_played = 1.day.ago.to_i
          h.games = 50
          h.win   = 25
          h.with_games = 40
          h.with_win   = 30
          h.against_games = 60
          h.against_win   = 40
        end

        array
      end

      dispatch_message("/heroes", from: {id: user.telegram_id})
    end

    it "should have the correct amount of pages" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.first.to_s)
      .to include("\"1 / 5\"")
    end

    it "should have the correct buttons on page 1" do
      row = bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last
      
      expect(row.first.to_s)
      .to  include("\"1 / 5\"")
      .and include("\"nothing:0\"")
      expect(row.second.to_s)
      .to  include("\">\"")
      .and include("\"pagination:2\"")
      expect(row.third.to_s)
      .to  include("\">>|\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on page 2" do
      dispatch(callback_query: {
        data: "pagination:2", message: {message_id: 125, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.first.to_s)
      .to  include("\"<\"")
      .and include("\"pagination:1\"")
      expect(row.second.to_s)
      .to  include("\"2 / 5\"")
      .and include("\"nothing:0\"")
      expect(row.third.to_s)
      .to  include("\">\"")
      .and include("\"pagination:3\"")
      expect(row.fourth.to_s)
      .to  include("\">>|\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on page 3" do
      dispatch(callback_query: {
        data: "pagination:3", message: {message_id: 125, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.first.to_s)
      .to  include("\"|<<\"")
      .and include("\"pagination:1\"")
      expect(row.second.to_s)
      .to  include("\"<\"")
      .and include("\"pagination:2\"")
      expect(row.third.to_s)
      .to  include("\"3 / 5\"")
      .and include("\"nothing:0\"")
      expect(row.fourth.to_s)
      .to  include("\">\"")
      .and include("\"pagination:4\"")
      expect(row.fifth.to_s)
      .to  include("\">>|\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on page 4" do
      dispatch(callback_query: {
        data: "pagination:4", message: {message_id: 125, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.first.to_s)
      .to  include("\"|<<\"")
      .and include("\"pagination:1\"")
      expect(row.second.to_s)
      .to  include("\"<\"")
      .and include("\"pagination:3\"")
      expect(row.third.to_s)
      .to  include("\"4 / 5\"")
      .and include("\"nothing:0\"")
      expect(row.fourth.to_s)
      .to  include("\">\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on page 5" do
      dispatch(callback_query: {
        data: "pagination:5", message: {message_id: 125, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.first.to_s)
      .to  include("\"|<<\"")
      .and include("\"pagination:1\"")
      expect(row.second.to_s)
      .to  include("\"<\"")
      .and include("\"pagination:4\"")
      expect(row.third.to_s)
      .to  include("\"5 / 5\"")
      .and include("\"nothing:0\"")
    end
  end
end
