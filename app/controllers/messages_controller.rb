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
    # creation d'un nouveau message
    @chat = current_user.chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = 'user'
    if @message.save
      # 2- ON CREE L'ASSISTANT
      ruby_llm = RubyLLM.chat.with_instructions(instructions)
      # 3- ON POSE LA QUESTION A L'ASSISTANT
      response = ruby_llm.ask(@message.content)
      # 4- ON STOCK LA REPONSE DE L'ASSISTANT EN DB POUR INITIER UNE CONVERSATION
      Message.create(content: response.content, role: "assistant", chat: @chat)
      @chat.generate_title_from_first_message
      redirect_to chat_path(@chat)
    else
      render "chats/show"
    end
  end

  private

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
