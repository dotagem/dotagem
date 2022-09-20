RSpec.describe User do
  context "with valid attributes" do
    it "should be valid without steam account" do
      expect( build(:user) )
      .to be_valid
    end

    it "should be valid with steam account" do
      expect( build(:user, :steam_registered) )
      .to be_valid
    end

    it "should accept several incomplete users" do
      create(:user)
      expect( build(:user) )
      .to be_valid
    end
  end

  context "telegram_id" do
    it "should not be missing" do
      expect( build(:user, telegram_id: nil) )
      .to be_invalid
    end

    it "should not already exist in the database" do
      user = create(:user)

      expect( build(:user, telegram_id: user.telegram_id) )
      .to be_invalid
    end
  end

  context "telegram_username" do
    it "should not be missing" do
      expect( build(:user, telegram_username: nil) )
      .to be_invalid
    end

    it "should not be blank" do
      expect( build(:user, telegram_username: "") )
      .to be_invalid
    end

    it "should not already exist in the database" do
      user = create(:user)

      expect( build(:user, telegram_username: user.telegram_username) )
      .to be_invalid
    end
  end

  context "steam_id" do
    it "should be numerical" do
      expect( build(:user, :steam_registered, steam_id: "1234a") )
      .to be_invalid
    end

    it "should not already exist in the database" do
      user = create(:user, :steam_registered)

      expect( build(:user, :steam_registered, steam_id: user.steam_id) )
      .to be_invalid
    end
  end

  context "steam_id64" do
    it "should not already exist in the database" do
      user = create(:user, :steam_registered)

      expect( build(:user, :steam_registered, steam_id64: user.steam_id64) )
      .to be_invalid
    end
  end
end
