class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  has_one :result, dependent: :destroy
end
