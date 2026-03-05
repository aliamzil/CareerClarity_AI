class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  has_one :result, dependent: :destroy

  DEFAULT_TITLE = "Untitled"
  TITLE_PROMPT = <<~PROMPT
    Generate a short, descriptive, 3-to-5-word title that summarizes the user question for a chat conversation.
  PROMPT

  def generate_title_from_first_message
    return unless title == DEFAULT_TITLE

    first_user_message = messages.where(role: "user").order(:created_at).first
    return if first_user_message.nil?

      response = RubyLLM.chat.with_instructions(TITLE_PROMPT).ask(first_user_message.content)
      update(title: response.content)

    validates :title, presence: true
    validates :persona, presence: true
  end
end
