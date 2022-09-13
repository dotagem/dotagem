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
    it "should say you need to register" do
      expect { dispatch_message("/rank") }
      .to respond_with_message(/You need to register before/)
    end
  end

  context "as an incomplete user" do
    it "should say you need to complete their registration" do
      user = create(:user)
      expect { dispatch_message("/rank", from: {id: user.telegram_id}) }
      .to respond_with_message(/You need to complete your registration/)
    end
  end
  
  context "with no arguments" do
    it "should return the user's rank" do
      expect { dispatch_message("/rank", from: {id: user.telegram_id}) }
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

      expect { dispatch_message("/rank", from: {id: user.telegram_id}) }
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

      expect { dispatch_message("/rank", from: {id: user.telegram_id}) }
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

      expect { dispatch_message("/rank", from: {id: user.telegram_id}) }
      .to  respond_with_message("@#{user.telegram_username}'s rank is Immortal")
    end
  end

  context "with an unknown user in args" do
    it "should say it can't find that user" do
      dispatch_message("/rank sdfkjsdkfsd", from: {id: user.telegram_id})

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Can't find that user")
    end
  end

  context "with an incomplete user in args" do
    it "should tell that user to complete their registration" do
      user2 = create(:user)

      dispatch_message(
        "/rank #{user2.telegram_username}",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("has not completed their registration")
      .and not_include(user.telegram_username)
      .and not_include(user2.telegram_username)
    end
  end

  context "with another valid user in args" do
    it "should give that user's rank" do
      user2 = create(:user, :steam_registered)

      dispatch_message(
        "/rank #{user2.telegram_username}",
        from: {id: user.telegram_id}
      )

      expect(bot.requests[:sendMessage].last[:text])
      .to  include("Legend 5")
      .and include(user2.telegram_username)
      .and not_include(user.telegram_username)
    end
  end
end
