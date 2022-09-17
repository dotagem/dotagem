class Nickname < ApplicationRecord
  default_scope { order(:name) }

  validates :hero_id, presence: true
  validates :name,  presence: true,
                    format: { with: /\A[a-z\- ]+\z/, message: "must be lowercase letters only" },
                    uniqueness: { scope: :hero_id, message: "already exists for that hero" }

  belongs_to :hero, primary_key: :hero_id
end
