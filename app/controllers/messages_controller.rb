class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = 'user'
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def set_message
    @message = Chat.find(params[:id])
  end
end
