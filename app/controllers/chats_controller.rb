class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show]
  def index
    @chats = current_user.chats
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
    @messages = @chat.messages
  end

  def new
    @chat = Chat.new
  end

  def create
    @chat = Chat.new(chat_params)
    @chat.user = current_user
    @chat.persona = params[:persona]
    @chat.title = Chat::DEFAULT_TITLE # On initialise avec le titre par défaut
    # @chat = current_user.chats.new(chat_params) # en 1 ligne
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render "pages/home", status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:title)
  end
end
