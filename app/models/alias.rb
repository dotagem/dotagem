class Alias < ApplicationRecord
  validates :name, uniqueness: { scope: :hero_id }
  
  belongs_to :hero, primary_key: :hero_id
end
