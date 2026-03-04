class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = "Tu es CareerClarity, un coach en carrière professionnel expert et bienveillant.
  Ton rôle est d'aider :
  - Les employés qui veulent évoluer ou changer de poste - Les personnes sans emploi qui cherchent un travail
  - Les freelances qui veulent développer leur activité. Tu peux aider avec : - La préparation aux entretiens d'embauche
  - La rédaction et l'amélioration de CV
  - La négociation de salaire - La reconversion professionnelle
  - La définition d'un plan de carrière
  - La confiance en soi et la motivation Ton style :
  - Bienveillant et encourageant
  - Concret et actionnable
  - Pose des questions pour mieux comprendre la situation
  - Donne des exemples précis
  - Tu ne parles QUE de carrière et de travail
  - Si on te parle d'autre chose, redirige vers le sujet carrière
  - Commence toujours par comprendre la situation de l'utilisateur"

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = 'user'

    if @message.save
      # Correction : Utilisation d'une méthode plus simple pour l'historique
      @ruby_llm_chat = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)

      # On ajoute les anciens messages à l'IA pour qu'elle ait de la mémoire
      @chat.messages.where.not(id: @message.id).each do |msg|
        @ruby_llm_chat.add_message(role: msg.role, content: msg.content)
      end

      # On pose la question avec le contenu du nouveau message
      response = @ruby_llm_chat.ask(@message.content)

      # Sauvegarde de la réponse de l'IA
      Message.create(content: response.content, role: "assistant", chat: @chat)

      # Mise à jour du titre si c'est le premier message
      @chat.generate_title_from_first_message

      redirect_to chat_path(@chat)
    else
      @messages = @chat.messages
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def set_message
    @message = Chat.find(params[:id])
  end

  def instructions
    [SYSTEM_PROMPT, chat_context, @chat.system_prompt].compact.join("\n\n")
  end
end
