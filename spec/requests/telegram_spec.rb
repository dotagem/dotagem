RSpec.describe "Telegram bot", telegram_bot: :rails do
  it "should welcome new group members" do
    dispatch(message: {
      from: {id: 12345, username: "asdfgh"},
      chat: {id: 456},
      new_chat_member: {
        id: 12345, username: "asdfgh"
      }
    })

    expect(bot.requests[:sendMessage].last[:text])
    .to  include("Welcome! I can fetch your Dota 2 match data")
    .and include("use the button below to log in with your Steam")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)
    
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Log In\"")
    .and include("/auth/telegram/callback\"")
    .and include(":login_url")
  end

  it "should welcome incomplete users" do
    user = create(:user)
    dispatch(message: {
      from: {id: user.telegram_id, username: user.telegram_username},
      chat: {id: 456},
      new_chat_member: {
        id: user.telegram_id, username: user.telegram_username
      }
    })

    expect(bot.requests[:sendMessage].last[:text])
    .to  include("Welcome! I can fetch your Dota 2 match data")
    .and include("use the button below to log in with your Steam")

    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].count)
    .to eq(1)
    
    expect(bot.requests[:sendMessage].last[:reply_markup][:inline_keyboard].first.to_s)
    .to  include("\"Log In\"")
    .and include("/auth/telegram/callback\"")
    .and include(":login_url")
  end

  it "should not welcome users that are already registered" do
    user = create(:user, :steam_registered)

    dispatch(message: {
      from: {id: user.telegram_id, username: user.telegram_username},
      chat: {id: 456},
      new_chat_member: {
        id: user.telegram_id, username: user.telegram_username
      }
    })

    expect(bot.requests[:sendMessage].count).to eq(0)
  end

  it "should not welcome itself" do
    dispatch(message: {
      from: {id: bot.id, username: bot.username},
      chat: {id: 456},
      new_chat_member: {
        id: bot.id, username: bot.username
      }
    })

    expect(bot.requests[:sendMessage].count).to eq(0)
  end

  it "should introduce itself when added to a group" do
    user = create(:user, :steam_registered)
    dispatch(my_chat_member: {
      from: { id: user.telegram_id, username: user.telegram_username },
      chat: { id: 456 },
      new_chat_member: {
        user: {
          id: bot.id,
          username: bot.username
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
    .and include(":login_url")
    .and include("/auth/telegram/callback\"")
  end
end
