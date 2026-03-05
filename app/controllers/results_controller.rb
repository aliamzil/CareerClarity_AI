# app/controllers/results_controller.rb
class ResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat

  def create
    # On demande à l'IA de faire le bilan basé sur TOUT le chat
    prompt_final = "Analyse toute notre conversation et génère maintenant la roadmap en étapes concrètes."

    ruby_llm = RubyLLM.chat.with_instructions(MessagesController::SYSTEM_PROMPT)

    # On passe l'historique complet
    history = @chat.messages.map { |m| { role: m.role, content: m.content } }
    response = ruby_llm.ask(prompt_final, history: history)

    # ON CREE LE RESULTAT
    @result = Result.new(chat: @chat, roadmap: response.content)

    if @result.save
      redirect_to chat_result_path(@chat)
    else
      redirect_to chat_path(@chat), alert: "Erreur lors de la génération."
    end
  end

  def show
    @result = @chat.result
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end
end

# class ResultsController < ApplicationController
#   before_action :authenticate_user!

#   SYSTEM_RESULT = "A la fin de cet échange, tu feras un compte
#   rendu constructif et les démarches à suivre sous forme d'étape."

#   def create
#     # 1 - ON CREE LE MESSAGE INITIAL DU USER
#     @chat = current_user.chats.find(params[:chat_id])
#     # 2- ON CREE L'ASSISTANT
#     ruby_llm = RubyLLM.chat.with_instructions(instructions)
#     # 3- ON POSE LA QUESTION A L'ASSISTANT
#     response = ruby_llm.ask(@message.content)
#     # 4- ON STOCK LA REPONSE DE L'ASSISTANT EN DB POUR INITIER UNE CONVERSATION
#     Message.create(content: response.content, role: "assistant", chat: @chat)
#   end

#   def show
#     @result = @chat.result
#   end

#   private

#   def message_params
#     params.require(:message).permit(:content)
#   end

#   def instructions
#     [SYSTEM_PROMPT].compact.join("\n\n")
#   end
# end
