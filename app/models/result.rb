class Result < ApplicationRecord
  belongs_to :chat

  validates :roadmap, presence: true
end
