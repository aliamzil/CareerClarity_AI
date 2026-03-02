class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show]
  def index
    @chat = current_user.chats
  end

  def show
    @messages = @chat.messages
    @message = Message.new
  end

  def new
    @chat = Chat.new
  end

  def create
    @chat = Chat.new(chat_params)
    @chat.user = current_user
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:title, :persona)
  end
end
