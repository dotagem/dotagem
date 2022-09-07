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
    
  end

  context "pagination" do

  end
end
