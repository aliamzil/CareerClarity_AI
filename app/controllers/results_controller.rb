class ResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat
  # 1. On prépare un prompt spécifique pour la synthèse
  PROMPT_SYSTEM = <<~PROMPT
    Analyse toute notre conversation précédente.
    Génère une roadmap de carrière concrète en 3 à 5 étapes clés.
    Utilise du **gras** et des listes à puces pour la lisibilité.
    Sois concis et encourageant.
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
