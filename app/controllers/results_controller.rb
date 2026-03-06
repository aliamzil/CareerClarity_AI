class ResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat
  # 1. On prépare un prompt spécifique pour la synthèse
  # #<<~PROMPT
    #Analyse toute notre conversation précédente.
    #Génère une roadmap de carrière concrète en 3 à 5 étapes clés.
    #Utilise du **gras** et des listes à puces pour la lisibilité.
    #Sois concis et encourageant.
 # PROMPT
 PROMPT_SYSTEM =<<~PROMPT
  Tu es un coach de carrière expert et bienveillant.

  **Contexte :** Analyse l'intégralité de notre conversation précédente pour extraire les informations clés sur mon profil, mes ambitions et mes contraintes.

  **Ta mission :** Génère une roadmap de carrière personnalisée en 3 à 5 étapes concrètes et actionnables.

  **IMPORTANT — Format de réponse :** Réponds UNIQUEMENT en HTML valide, sans balise <html>, <head> ou <body>. Utilise exactement cette structure :

  <p class="intro-text">[Phrase d'introduction personnalisée]</p>

  <div class="step">
    <h2>[Titre de l'étape]</h2>
    <ul>
      <li>[Action concrète 1]</li>
      <li>[Action concrète 2]</li>
      <li>[Action concrète 3]</li>
    </ul>
  </div>

  <!-- Répète <div class="step"> pour chaque étape, sans numéro -->

  <p class="encourage">💡 [Note d'encouragement personnalisée, 2-3 lignes max]</p>

  **Contraintes de contenu :**
  - 3 à 5 étapes maximum
  - 2 à 3 actions par étape, concises (1 phrase chacune)
  - Aucun numéro, aucun chiffre isolé — les titres suffisent
  - Aucune ligne vide inutile entre les blocs
  - Ton encourageant mais réaliste, ancré dans le profil de la conversation
PROMPT

  # POST /chats/:chat_id/results
  def create
    # 2. On initialise l'IA avec le prompt système d'origine
    ruby_llm = RubyLLM.chat.with_instructions(MessagesController::SYSTEM_PROMPT)

    # 4. On appelle l'IA
    begin
      response = ruby_llm.ask(instructions)

      # 5. On crée ou on met à jour le résultat
      @result = Result.find_or_create_by(chat: @chat)
      @result.roadmap = response.content

      if @result.save
        redirect_to chat_result_path(@chat, @result)
      else
        redirect_to chat_path(@chat), alert: "Impossible de sauvegarder la roadmap."
      end
    rescue RubyLLM::Error => e
      redirect_to chat_path(@chat), alert: "L'IA est indisponible pour le moment."
    end
  end

  # GET /chats/:chat_id/results/:id (ou result)
  def show
    @result = @chat.result
    # Si l'utilisateur tape l'URL du résultat alors qu'il n'est pas encore généré
    redirect_to chat_path(@chat), alert: "Générez d'abord votre roadmap." if @result.nil? || @result.roadmap.blank?
  end

  private

  def set_chat
    # Sécurité : on cherche le chat uniquement dans ceux de l'utilisateur actuel
    @chat = current_user.chats.find(params[:chat_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to chats_path, alert: "Conversation introuvable."
  end

  def chat_history
    # 3. On récupère l'historique complet du chat pour que l'IA ait tout le contexte
    @chat.messages.map { |m| { role: m.role, content: m.content } }.join(",")
  end

  def instructions
    [PROMPT_SYSTEM, chat_history].compact.join
  end
end
