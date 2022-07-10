class MessagesController < ApplicationController
  
  before_action :set_chatroom
  before_action :set_message, only: %i[ edit update destroy ]
  
  # GET chatrooms/:chatroom_id/messages/new
  def new
    @message = @chatroom.messages.new
  end

  # GET chatrooms/:chatroom_id/messages/1/edit
  def edit
  end

  # POST chatrooms/:chatroom_id/messages or /messages.json
  def create
    @message = @chatroom.messages.build(message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        @message.broadcast_append_later_to [@chatroom, "messages"], target: "chatroom_messages", partial: "messages/other_user_message", locals: {chatroom: @chatroom, other_user_message: @message, current_user: current_user}
        #@chatroom.broadcast_prepend_later_to [@participation.user, "chatrooms"], target: "pending_chatrooms", partial: "chatrooms/chatroom_pending", locals: {chatroom_pending: @chatroom}
        
        format.turbo_stream
        format.html { redirect_to chatroom_path(@chatroom), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT chatroom/:chatroom_id/messages/1
  def update
    respond_to do |format|
      if @message.update(message_params)
        @message.broadcast_replace_later_to [@chatroom, "messages"], locals: {chatroom: @chatroom, current_user: current_user}, target: "message_#{@message.id}"

        format.turbo_stream
        format.html { redirect_to chatroom_path(@chatroom), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy
    @message.broadcast_remove_to [@chatroom, "messages"], target: "message_#{@message.id}"
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Message was successfully deleted." }
      format.html { redirect_to chatroom_path(@chatroom), notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Message always belongs_to Chatroom, so we will often need the chatroom instance
    def set_chatroom
      if params[:chatroom_id]
        @chatroom = Chatroom.find(params[:chatroom_id])
      end
    end

    # Set message when :id is present and is the message id
    def set_message
      @message = @chatroom.messages.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:content, :user_id, :chatroom_id)
    end
end
