RSpec.describe "Telegram bot", telegram_bot: :rails do
  describe "user data" do
    let(:user)  { create(:user, :steam_registered) }

    it "should add users to the database when they run a command" do
      user2 = build(:user)

      expect(User.find_by(telegram_id: user2.telegram_id))
      .to eq(nil)

      dispatch_message("/help", from: {
        id: user2.telegram_id,
        username: user2.telegram_username,
        first_name: user2.telegram_name
      })

      expect(User.find_by(telegram_id: user2.telegram_id))
      .to be_present
    end

    it "should update user's username when they run a command" do
      original_username = user.telegram_username
      new_username = "abcdefg"

      expect(user.telegram_username).to eq(original_username).and not_eq(new_username)

      dispatch_message("/help", from: {
        id: user.telegram_id,
        username: new_username,
        first_name: user.telegram_name
      })

      expect(user.reload.telegram_username).to eq(new_username).and not_eq(original_username)
    end

    it "should update user's name when they run a command" do
      original_name = user.telegram_name
      new_name = "Hello"

      expect(user.telegram_name).to eq(original_name).and not_eq(new_name)

      dispatch_message("/help", from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: new_name
      })

      expect(user.reload.telegram_name).to eq(new_name).and not_eq(original_name)
    end

    it "should put first and last name together correctly" do
      original_name = user.telegram_name

      expect(user.telegram_name).to eq(original_name)

      dispatch_message("/help", from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: "Hello",
        last_name: "World"
      })

      expect(user.reload.telegram_name).to eq("Hello World").and not_eq(original_name)
    end

    it "should update when user runs a callback query" do
      dispatch(callback_query: {
        data: "nothing:0", message: {message_id: 60, chat: {id: 456}},
        from: {
          id: user.telegram_id,
          username: "hehexd",
          first_name: "Lol Lmao"
        }
      })

      expect(user.reload.telegram_username).to eq("hehexd")
      expect(user.reload.telegram_name).to eq("Lol Lmao")
    end

    it "should update when user runs an inline query" do
      dispatch(
        inline_query: {
          id:   "347",
          from: {
            id: user.telegram_id,
            username: "hehexd",
            first_name: "Lol Lmao"
          },
          query: "spirit"
        }
      )

      expect(user.reload.telegram_username).to eq("hehexd")
      expect(user.telegram_name).to eq("Lol Lmao")
    end
  end

  it "should welcome new group members" do
    dispatch(message: {
      from: {
        id: 12345,
        username: "asdfgh",
        first_name: "Aaa"
      },
      chat: { id: 456 },
      new_chat_member: {
        id: 12345,
        username: "asdfgh",
        first_name: "Aaa"
      }
    })

    expect(bot.requests[:sendMessage].last[:text])
    .to  include("Welcome! I can fetch your Dota 2 match data")
    .and include("use the button below to log in with your Steam")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)
    
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Log In\"")
    .and include("\"https://t.me/")
    .and include("?start=login")
    .and include(":url")
  end

  it "should welcome incomplete users" do
    user = create(:user)
    dispatch(message: {
      from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      },
      chat: {id: 456},
      new_chat_member: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      }
    })

    expect(bot.requests[:sendMessage].last[:text])
    .to  include("Welcome! I can fetch your Dota 2 match data")
    .and include("use the button below to log in with your Steam")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)
    
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Log In\"")
    .and include("\"https://t.me/")
    .and include("?start=login")
    .and include(":url")
  end

  it "should not welcome users that are already registered" do
    user = create(:user, :steam_registered)

    dispatch(message: {
      from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      },
      chat: {id: 456},
      new_chat_member: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      }
    })

    expect(bot.requests[:sendMessage].count).to eq(0)
  end

  it "should not welcome itself" do
    dispatch(message: {
      from: {
        id: bot.id,
        username: bot.username,
        first_name: "Bot"
      },
      chat: {id: 456},
      new_chat_member: {
        id: bot.id,
        username: bot.username,
        first_name: "Bot"
      }
    })

    expect(bot.requests[:sendMessage].count).to eq(0)
  end

  it "should introduce itself when added to a group" do
    user = create(:user, :steam_registered)
    dispatch(my_chat_member: {
      from: {
        id: user.telegram_id,
        username: user.telegram_username,
        first_name: user.telegram_name
      },
      chat: { id: 456 },
      new_chat_member: {
        user: {
          id: bot.id,
          username: bot.username,
          first_name: "Bot"
        }
      }
    })

    expect(bot.requests[:sendMessage].last[:text])
    .to  include("Hello! I can fetch your Dota 2 match data")
    .and include("To let me show your stats, I will need")
    .and include("log in with the button below and complete")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Log In\"")
    .and include("\"https://t.me/")
    .and include("?start=login")
    .and include(":url")
  end
end
