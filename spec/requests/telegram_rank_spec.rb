RSpec.describe "/rank", telegram_bot: :rails do
  let(:user) { create(:user, :steam_registered) }
  before(:example) do
    allow_any_instance_of(OpendotaPlayers).to receive(:info) { 
      {
        "leaderboard_rank"=>nil,
        "rank_tier"=>55
      }
    }
  end
  
  context "as an unregistered user" do
    before(:example) do
      dispatch_message("/rank")
    end

    it "should say you need to register" do
      expect(bot.requests[:sendMessage].last[:text])
      .to include("You need to register before")
    end

    it "should provide a button to pm the bot" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In\"")
      .and include("https://t.me/")
      .and include(":url")
    end
  end

  context "as an incomplete user" do
    let(:user) { create(:user) }
    
    before(:example) do
      dispatch_message("/rank", from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      })
    end

    it "should say that you need to register" do
      expect(bot.requests[:sendMessage].last[:text])
      .to include("You need to register before")
    end

    it "should provide a button to pm the bot" do
      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
      .to eq(1)

      expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("\"Log In\"")
      .and include("https://t.me/")
      .and include(":url")
    end
  end

  context "mentioning an unknown user" do
    it "should say it doesn't know that user" do
      expect(bot).to receive(:request).and_wrap_original do |m, *args|
        m.call(*args)
        {"ok"=>true, "result"=>{"message_id"=>120}}
      end

      expect { dispatch_message("/rank asdfsf", from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      }) }
      .to  respond_with_message(/I don't know that user, sorry!/)
      .and respond_with_message(/They may not be registered yet./)
    end
  end
  
  context "mentioning an incomplete user" do
    it "should say that user needs to complete their registration" do
      user2 = create(:user)
      expect { dispatch_message(
        "/rank #{user2.telegram_username}", from: {
          id: user.telegram_id,
          username: user.telegram_username,
          first_name: user.telegram_name
        }
      ) }
      .to  respond_with_message(/That user has not signed in/)
      .and respond_with_message(/Once they sign in, their data will become available/)
    end
  end
  
  context "with no arguments" do
    it "should return the user's rank" do
      expect { dispatch_message("/rank", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }) }
      .to  respond_with_message(/@#{user.telegram_username}/)
      .and respond_with_message(/rank is Legend 5/)
    end

    it "should format unranked players correctly" do
      allow_any_instance_of(OpendotaPlayers).to receive(:info) {
        {
          "leaderboard_rank"=>nil,
          "rank_tier"=>nil
        }
      }

      expect { dispatch_message("/rank", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }) }
      .to  respond_with_message(/@#{user.telegram_username}/)
      .and respond_with_message(/Uncalibrated/)
    end

    it "should format leaderboard players correctly" do
      allow_any_instance_of(OpendotaPlayers).to receive(:info) {
        {
          "leaderboard_rank"=>1234,
          "rank_tier"=>80
        }
      }

      expect { dispatch_message("/rank", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }) }
      .to  respond_with_message(/@#{user.telegram_username}/)
      .and respond_with_message(/Immortal 1234/)
    end

    it "should format immortals without leaderboard position correctly" do
      allow_any_instance_of(OpendotaPlayers).to receive(:info) {
        {
          "leaderboard_rank"=>nil,
          "rank_tier"=>80
        }
      }

      expect { dispatch_message("/rank", from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }) }
      .to  respond_with_message("@#{user.telegram_username}'s rank is Immortal")
    end
  end

  context "with another valid user in args" do
    it "should give that user's rank" do
      user2 = create(:user, :steam_registered)

      dispatch_message(
        "/rank #{user2.telegram_username}",
        from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          }
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Legend 5")
      .and include(user2.telegram_username)
      .and not_include(user.telegram_username)
    end
  end
end
