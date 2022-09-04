RSpec.describe TelegramPlayersController, telegram_bot: :rails do
  describe "#matches!" do
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
        request_method = bot.method(:request)
        expect(bot).to receive(:request) do |*args|
          request_method.call(*args)
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

    #   it "should paginate more than 5 results" do

    #   end

    #   it "should not paginate less than 6 results" do

    #   end
    end

    # context "with clear arguments" do
    #   it "should handle hero arguments" do

    #   end

    #   it "should handle teammate arguments" do

    #   end

    #   it "should be able to fetch matches for a different player" do

    #   end

    #   it "should return matches for those arguments" do

    #   end

    #   it "should not return other matches" do

    #   end
    # end

    # context "with aliases" do
    #   it "should ask for clarification" do

    #   end

    #   it "should pick the correct hero after button press" do

    #   end

    #   it "should ask multiple times if necessary" do

    #   end

    #   it "should return a list of matches once everything is clear" do

    #   end
    # end
  end
  
  describe "#profile!" do
    context "as a registered user" do
      it "should respond with their steam url" do
        user = create(:user, :steam_registered)
        dispatch_message("/profile", from: {id: user.telegram_id})
        expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
      end
    end

    context "as an unregistered user" do
      it "should tell the user they're not registered" do
        expect {dispatch_message("/profile")}
        .to respond_with_message(/Can't find that user/)
      end
    end

    context "as an incomplete user" do
      it "should tell the user to complete their registration" do
        user = create(:user)
        expect {dispatch_message("/profile", from: {id: user.telegram_id})}
        .to respond_with_message(/That user has not completed their registration/)
      end
    end

    context "mentioning a registered user" do
      it "should respond with that user's steam link" do
        user = create(:user, :steam_registered)
        dispatch_message("/profile #{user.telegram_username}")
        expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
      end

      it "should not respond with the caller's steam link" do
        user  = create(:user, :steam_registered)
        user2 = create(:user, :steam_registered)
        dispatch_message("/profile #{user2.telegram_username}", from: {id: user.telegram_id})
        expect(bot.requests[:sendMessage].last[:text]).not_to include(user.steam_url)
      end
    end

    context "mentioning an unregistered user" do
      it "should say it can't find that user" do
        expect { dispatch_message("/profile asdfasdfsdf") }
        .to respond_with_message(/Can't find that user/)
      end
    end

    context "mentioning an incomplete user" do
      it "should tell the user to complete their registration" do
        user = create(:user)
        expect {dispatch_message("/profile #{user.telegram_username}")}
        .to respond_with_message(/That user has not completed their registration/)
      end
    end

    context "with invalid arguments" do
      it "should assume the current user" do
        user = create(:user, :steam_registered)
        dispatch_message("/profile asdsfgflkdg wehjkr", from: {id: user.telegram_id})
        expect(bot.requests[:sendMessage].last[:text]).to include(user.steam_url)
      end
    end
  end
end
