class Item < ApplicationRecord
  serialize :components

  def self.refresh
    ActiveRecord::Base.transaction do
      self.destroy_all

      OpendotaConstants.new("items").all.each do |item|
        i = self.new
        i.name    = item.first
        i.item_id = item.second["id"]

        # We don't want all the data, so iterate over attributes instead
        i.attributes.each_pair do |k, v|
          if v == nil && k != "id"
            i.send("#{k}=", item.second[k])
          end
        end
        i.save
      end
    end
  end
end
