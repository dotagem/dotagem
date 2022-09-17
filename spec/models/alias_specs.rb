RSpec.describe Nickname do
  context "with valid attributes" do
    it "should be valid" do
      expect( build(:nickname) )
      .to be_valid
    end
  end

  context "hero ID" do
    it "should not be missing" do
      expect( build(:nickname, hero_id: nil) )
      .to be_invalid
    end

    it "should match a hero" do
      expect( build(:nickname, hero_id: 999) )
      .to be_invalid
    end
  end

  context "name" do
    it "should not be missing" do
      expect( build(:nickname, name: nil) )
      .to be_invalid
    end

    it "should not be blank" do
      expect( build(:nickname, name: "") )
      .to be_invalid
    end

    it "should not be whitespace" do
      expect( build(:nickname, name: "    ") )
      .to be_invalid
    end

    it "should not contain capital letters" do
      expect( build(:nickname, name: "asDFgh") )
      .to be_invalid
    end

    it "should not contain numbers" do
      expect( build(:nickname, name: "asdf456") )
      .to be_invalid
    end

    it "should not contain special characters" do
      expect( build(:nickname, name: "asd&") )
      .to be_invalid

      expect( build(:nickname, name: "asd*") )
      .to be_invalid

      expect( build(:nickname, name: "asd^") )
      .to be_invalid

      expect( build(:nickname, name: "asd(") )
      .to be_invalid
    end

    it "should be able to contain spaces" do
      expect( build(:nickname, name: "hello world") )
      .to be_valid
    end

    it "should be able to contain a dash" do
      expect( build(:nickname, name: "asd-fgh") )
      .to be_valid
    end
  end

  context "duplicates" do
    it "should be valid for different heroes" do
      create(:nickname, name: "hehexd", hero_id: 1)

      expect( build(:nickname, name: "hehexd", hero_id: 2) )
      .to be_valid
    end

    it "should be invalid for the same hero" do
      create(:nickname, name: "asdfgh")

      expect( build(:nickname, name: "asdfgh") )
      .to be_invalid
    end
  end
end
