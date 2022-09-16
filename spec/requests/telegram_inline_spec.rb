RSpec.describe "Inline query", telegram_bot: :rails do
  let(:user) { create(:user, :steam_registered) }

  context "as an unregistered account" do
    before(:example) do
      dispatch(
        inline_query: {
          id:   "300",
          from: {id: 123},
          query: ""
        }
      )
    end

    it "should not return any results" do
      expect(bot.requests[:answerInlineQuery].last[:results].count)
      .to eq(0)
    end

    it "should have a button to switch to DMs" do
      expect(bot.requests[:answerInlineQuery].last[:switch_pm_text])
      .to  include("Log in with Steam")
    end

    it "should not be cached for long" do
      expect(bot.requests[:answerInlineQuery].last[:cache_time])
      .to eq(10)
    end
  end

  context "as an incomplete account" do
    let(:user) { create(:user) }

    before(:example) do
      dispatch(
        inline_query: {
          id:   "310",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: ""
        }
      )
    end

    it "should not return any results" do
      expect(bot.requests[:answerInlineQuery].last[:results].count)
      .to eq(0)
    end

    it "should have a button to switch to DMs" do
      expect(bot.requests[:answerInlineQuery].last[:switch_pm_text])
      .to  include("Log in with Steam")
    end

    it "should not be cached for long" do
      expect(bot.requests[:answerInlineQuery].last[:cache_time])
      .to eq(10)
    end
  end

  context "without query" do    
    before(:example) do
      allow_any_instance_of(User).to receive(:matches) {
        build_list(:list_match, 10)
      }

      dispatch(
        inline_query: {
          id:   "320",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: ""
        }
      )
    end

    it "should respond with matches" do
      expect(bot.requests[:answerInlineQuery].last[:results].count)
      .to eq(10)
    end

    it "should have the right title" do
      expect(bot.requests[:answerInlineQuery].last[:results].first[:title])
      .to include("Win as Anti-Mage")
    end

    it "should have the right description" do
      expect(bot.requests[:answerInlineQuery].last[:results].first[:description])
      .to  include("10/3/5 in 30 min")
      .and include("1 hour ago")
    end

    it "should have the right thumbnail" do
      expect(bot.requests[:answerInlineQuery].last[:results].first[:thumb_url])
      .to eq("https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/icons/antimage.png?")
    end

    it "should have the right message content" do
      expect(bot.requests[:answerInlineQuery].last[:results].first[:input_message_content][:message_text])
      .to  include("Recent match for #{user.telegram_username}")
      .and include("Hero: Anti-Mage")
      .and include("Result: Win in 30 mins")
      .and include("1 hour ago")
      .and include("10/3/5")
      .and include("90/10")
      .and include("US East")
    end

    it "should have the right inline button" do
      expect(bot.requests[:answerInlineQuery].last[:results].first[:reply_markup][:inline_keyboard].count)
      .to eq(1)

      expect(bot.requests[:answerInlineQuery].last[:results].first[:reply_markup][:inline_keyboard].first.to_s)
      .to  include("Match details on OpenDota")
      .and include("https://opendota.com/matches/")
    end

    it "should be marked personal" do
      expect(bot.requests[:answerInlineQuery].last[:is_personal])
      .to eq(true)
    end
  end

  context "with an invalid query" do
    it "should ask for matches without a hero argument" do
      expect_any_instance_of(User).to receive(:matches)
      .with(hash_excluding(:hero_id)) {
        []
      }

      dispatch(
        inline_query: {
          id:   "330",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: "dfsdfsd"
        }
      )
    end
  end

  context "with a single alias" do
    it "should ask for matches as that hero" do
      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 62)) {
        []
      }

      dispatch(
        inline_query: {
          id:   "340",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: "gondar"
        }
      )
    end
  end

  context "with an ambiguous alias" do
    before(:example) do
      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 17)) {
        [build(:list_match, hero_id: 17)]
      }

      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 20)) {
        [build(:list_match, hero_id: 20, start_time: 5.minutes.ago.to_i)]
      }

      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 71)) {
        [build(:list_match, hero_id: 71)]
      }

      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 106)) {
        [build(:list_match, hero_id: 106, start_time: 30.minutes.ago.to_i)]
      }

      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 107)) {
        build_list(:list_match, 20, hero_id: 107, start_time: 7.days.ago.to_i)
      }

      expect_any_instance_of(User).to receive(:matches)
      .with(hash_including(hero_id: 126)) {
        [build(:list_match, hero_id: 126, start_time: 1.day.ago.to_i)]
      }
    end

    it "should ask for matches as each possible hero" do
      dispatch(
        inline_query: {
          id:   "340",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: "spirit"
        }
      )
    end

    it "should show all these heroes in the result titles" do
      dispatch(
        inline_query: {
          id:   "345",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: "spirit"
        }
      )

      titles = []
      bot.requests[:answerInlineQuery].last[:results].each do |r|
        titles << r[:title]
      end
      expect(titles)
      .to  include("Win as Earth Spirit")
      .and include("Win as Ember Spirit")
      .and include("Win as Spirit Breaker")
      .and include("Win as Storm Spirit")
      .and include("Win as Vengeful Spirit")
      .and include("Win as Void Spirit")
    end

    it "should sort results by most recent" do
      dispatch(
        inline_query: {
          id:   "347",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: "spirit"
        }
      )

      expect(bot.requests[:answerInlineQuery].last[:results].first[:title])
      .to  include("Vengeful Spirit")
      .and not_include("Earth Spirit")
      .and not_include("Ember Spirit")
      .and not_include("Spirit Breaker")
      .and not_include("Storm Spirit")
      .and not_include("Void Spirit")

      expect(bot.requests[:answerInlineQuery].last[:results].last[:title])
      .to  include("Earth Spirit")
      .and not_include("Vengeful Spirit")
      .and not_include("Ember Spirit")
      .and not_include("Spirit Breaker")
      .and not_include("Storm Spirit")
      .and not_include("Void Spirit")
    end

    it "should not return more than 10 matches total" do
      dispatch(
        inline_query: {
          id:   "347",
          from: {
            id: user.telegram_id,
            username: user.telegram_username,
            first_name: user.telegram_name
          },
          query: "spirit"
        }
      )

      expect(bot.requests[:answerInlineQuery].last[:results].count)
      .to eq(10)
    end
  end
end
