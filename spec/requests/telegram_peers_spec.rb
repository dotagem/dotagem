RSpec.describe "/peers", telegram_bot: :rails do
  before(:example) do
    allow_any_instance_of(User).to receive(:peers) {
      build_list(:peer,  4)
    }
  end

  let(:user) { create(:user, :steam_registered) }

  context "as an unregistered user" do
    it "should say that user can't be found" do
      expect { dispatch_message("/peers") }
      .to respond_with_message(/Can't find that user/)
    end
  end

  context "as an incomplete user" do
    it "should say that user needs to complete their registration" do
      user = create(:user)
      expect { dispatch_message("/peers", from: {id: user.telegram_id}) }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "mentioning an unknown user" do
    it "should fall back to the current user" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>100}}
      end

      expect { dispatch_message("/peers asdfsf", from: {id: user.telegram_id}) }
      .to  respond_with_message(/Peers of #{user.telegram_username}/)
      .and respond_with_message(/4 results/)
    end
  end
  
  context "mentioning an incomplete user" do
    it "should say that user needs to complete their registration" do
      user2 = create(:user)
      expect { dispatch_message(
        "/peers #{user2.telegram_username}", from: {id: user.telegram_id}
      ) }
      .to respond_with_message(/That user has not completed their registration/)
    end
  end

  context "with no arguments" do
    it "should give a valid message" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>101}}
      end

      expect { dispatch_message("/peers", from: {id: user.telegram_id}) }
      .to  respond_with_message(/Peers of #{user.telegram_username}/)
      .and respond_with_message(/4 results/)
    end

    it "should pluralize results" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>102}}
      end

      allow_any_instance_of(User).to receive(:peers) {
        build_list(:peer, 1)
      }

      dispatch_message("/peers", from: {id: user.telegram_id})
      
      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Peers of #{user.telegram_username}")
      .and include("1 result")
      .and not_include("results")
    end

    it "should give a list of buttons" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>103}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(5)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include("50.0%")
      .and include("100 games")
      .and include("last about 1 hour ago")
      .and include("matches_with_player")
    end

    it "should be sortable" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>104}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("Sort:")
      .and include("[Games]")
      .and include("A-Z")
      .and include("Win %")
      .and include("Last")
    end

    it "should not be sortable with 1 result" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>105}}
      end

      allow_any_instance_of(User).to receive(:peers) {
        build_list(:peer, 1)
      }

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  not_include("Sort:")
      .and not_include("[Games]")
      .and not_include("A-Z")
      .and not_include("Win %")
      .and not_include("Last")
    end

    it "should paginate more than 5 results" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>106}}
      end

      allow_any_instance_of(User).to receive(:peers) {
        build_list(:peer, 12)
      }

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(7)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("1 / 3")
      .and include(">>|")
      .and not_include("|<<")
    end

    it "should not paginate less than 6 results" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>107}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(5)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to  include("50.0%")
      .and not_include(">>|")
      .and not_include("1 / ")
      .and not_include("|<<")
    end
  end

  context "sorting" do
    let(:user_games)   { create(:user, :steam_registered) }
    let(:user_winrate) { create(:user, :steam_registered) }
    let(:user_last)    { create(:user, :steam_registered) }
    let(:user_name)    { create(:user, :steam_registered, telegram_username: "a_user") }

    before(:example) do
      allow_any_instance_of(User).to receive(:peers) { [
        build(:peer, account_id: user_games.steam_id, with_games: 200),
        build(:peer, account_id: user_winrate.steam_id, with_win: 99),
        build(:peer, account_id: user_last.steam_id, last_played: 5.minutes.ago.to_i),
        build(:peer, account_id: user_name.steam_id)
      ] }
    end

    it "should sort by games played by default" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>108}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[Games]")
      .and not_include("[Win %]")
      .and not_include("[A-Z]")
      .and not_include("[Last]")

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include(user_games.telegram_username)
      .and not_include(user_winrate.telegram_username)
      .and not_include(user_last.telegram_username)
      .and not_include(user_name.telegram_username)
    end

    it "should sort by winrate when the button is pressed" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>109}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[Games]")
      .and not_include("[Win %]")

      dispatch(callback_query: {
        data: "change_peer_sort:win", message: {message_id: 109, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[Win %]")
      .and not_include("[Games]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include(user_winrate.telegram_username)
      .and not_include(user_games.telegram_username)
      .and not_include(user_last.telegram_username)
      .and not_include(user_name.telegram_username)
    end

    it "should sort alphabetically when the button is pressed" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>110}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[Games]")
      .and not_include("[A-Z]")

      dispatch(callback_query: {
        data: "change_peer_sort:alphabetical",
        message: {message_id: 110, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[A-Z]")
      .and not_include("[Games]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include(user_name.telegram_username)
      .and not_include(user_games.telegram_username)
      .and not_include(user_last.telegram_username)
      .and not_include(user_winrate.telegram_username)
    end

    it "should sort by last played when the button is pressed" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>111}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[Games]")
      .and not_include("[Last]")

      dispatch(callback_query: {
        data: "change_peer_sort:last_played", message: {message_id: 111, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("[Last]")
      .and not_include("[Games]")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].second.to_s)
      .to  include(user_last.telegram_username)
      .and not_include(user_games.telegram_username)
      .and not_include(user_winrate.telegram_username)
      .and not_include(user_name.telegram_username)
    end
  end

  context "pagination" do
    before(:example) do
      allow_any_instance_of(User).to receive(:peers) {
        build_list(:peer, 24)
      }
    end

    it "should have the correct amount of pages" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>112}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to include("1 / 5")
    end

    it "should go to the next page when the next button is pressed" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>113}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      dispatch(callback_query: {
        data: "pagination:2", message: {message_id: 113, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last.to_s)
      .to include("2 / 5")
    end

    it "should have the correct buttons on the first page" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>114}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      row = bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last

      expect(row.count).to eq(3)
      expect(row.first.to_s)
      .to  include("1 / 5")
      .and include("nothing:0")
      expect(row.second.to_s)
      .to  include("\">\"")
      .and include("\"pagination:2\"")
      expect(row.third.to_s)
      .to  include("\">>|\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on the second page" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>115}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      dispatch(callback_query: {
        data: "pagination:2", message: {message_id: 115, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.count).to eq(4)
      expect(row.first.to_s)
      .to  include("\"<\"")
      .and include("\"pagination:1\"")
      expect(row.second.to_s)
      .to  include("2 / 5")
      .and include("\"nothing:0\"")
      expect(row.third.to_s)
      .to  include("\">\"")
      .and include("\"pagination:3\"")
      expect(row.fourth.to_s)
      .to  include("\">>|\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on the third page" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>116}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      dispatch(callback_query: {
        data: "pagination:3", message: {message_id: 116, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.count).to eq(5)
      expect(row.first.to_s)
      .to  include("\"|<<\"")
      .and include("\"pagination:1\"")
      expect(row.second.to_s)
      .to  include("\"<\"")
      .and include("\"pagination:2\"")
      expect(row.third.to_s)
      .to  include("3 / 5")
      .and include("\"nothing:0\"")
      expect(row.fourth.to_s)
      .to  include("\">\"")
      .and include("\"pagination:4\"")
      expect(row.fifth.to_s)
      .to  include("\">>|\"")
      .and include("\"pagination:5\"")
    end

    it "should have the correct buttons on the second to last page" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>117}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      dispatch(callback_query: {
        data: "pagination:4", message: {message_id: 117, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.count).to eq(4)
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

    it "should have the correct buttons on the last page" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>118}}
      end

      dispatch_message("/peers", from: {id: user.telegram_id})

      dispatch(callback_query: {
        data: "pagination:5", message: {message_id: 118, chat: {id: 456}}
      })

      row = bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].last
      
      expect(row.count).to eq(3)
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

  context "pressing the buttons" do
    it "should lead to matches with that player" do
      allow(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>119}}
      end

      user2 = create(:user, :steam_registered)

      allow_any_instance_of(User).to receive(:peers) {
        [build(:peer, account_id: user2.steam_id)]
      }

      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 4)
      }

      dispatch_message("/peers", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].last.to_s)
      .to include("\"matches_with_player:#{user2.steam_id}\"")

      dispatch(callback_query: {
        data: "matches_with_player:#{user2.steam_id}", message: {message_id: 119, chat: {id: 456}}
      })

      expect(bot.requests[:editMessageText].last[:text])
      .to  include("Matches")
      .and include("With players: #{user2.telegram_username}")

      expect(bot.requests[:editMessageReplyMarkup].last[:reply_markup][:inline_keyboard].count)
      .to eq(4)
    end
  end
end
