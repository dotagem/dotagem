class Patch < ApplicationRecord
  validates :patch_id, presence: true,
                       uniqueness: true
  validates :name,     presence: true

  def self.refresh
    ActiveRecord::Base.transaction do
      self.destroy_all

      OpendotaConstants.new("patch").all.each do |patch|
        p = Patch.new
        p.patch_id = patch['id']
        p.name     = patch['name']
        p.date     = DateTime.iso8601(patch['date'])
        
        p.save
      end
    end
  end
end
