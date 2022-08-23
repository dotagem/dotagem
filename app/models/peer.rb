class Peer
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account_id
  attribute :last_played
  attribute :win
  attribute :games
  attribute :with_win
  attribute :with_games
  attribute :against_win
  attribute :against_games
  attribute :with_gpm_sum
  attribute :with_xpm_sum
  attribute :personaname
  attribute :name
  attribute :avatarfull

  def self.from_data(data)
    peer = self.new
    peer.attributes.each_pair do |k, _|
      peer.send("#{k}=", data[k])
    end
    peer
  end

  def known?
    User.find_by(steam_id: self.account_id).exists?
  end

  def persisted?
    false
  end
end
