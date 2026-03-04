class ResultsController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_RESULT = "A la fin de cet échange, tu feras un compte
  rendu constructif et les démarches à suivre sous forme d'étape."

  def create
    # 1 - ON CREE LE MESSAGE INITIAL DU USER
    @chat = current_user.chats.find(params[:chat_id])
    # 2- ON CREE L'ASSISTANT
    ruby_llm = RubyLLM.chat.with_instructions(instructions)
    # 3- ON POSE LA QUESTION A L'ASSISTANT
    response = ruby_llm.ask(@message.content)
    # 4- ON STOCK LA REPONSE DE L'ASSISTANT EN DB POUR INITIER UNE CONVERSATION
    Message.create(content: response.content, role: "assistant", chat: @chat)
  end

  def show
    @result = @chat.result
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def instructions
    [SYSTEM_PROMPT].compact.join("\n\n")
  end
end
