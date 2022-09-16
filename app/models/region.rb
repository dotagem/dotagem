class Region < ApplicationRecord
  validates :region_id,      presence: true,
                             uniqueness: true
  validates :name,           presence: true
  validates :localized_name, presence: true
  
  def self.refresh
    ActiveRecord::Base.transaction do
      self.destroy_all

      OpendotaConstants.new("region").all.each do |region|
        r = Region.new
        r.region_id      = region.first
        r.name           = region.second
        r.localized_name = region.second.downcase.titleize

        r.save
      end
    end
  end
end
