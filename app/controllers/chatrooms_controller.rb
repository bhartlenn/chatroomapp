class ChatroomsController < ApplicationController
  before_action :set_chatroom, only: %i[ show edit update destroy search_for_users invite_to_chatroom join_chatroom leave_chatroom ]

  # GET /chatrooms or /chatrooms.json
  def index
    @chatrooms = current_user.owned_chatrooms.ordered.load_async
    @joined_chatrooms = current_user.joined_chatrooms.ordered.load_async
    @pending_chatrooms = current_user.pending_chatrooms.ordered.load_async
  end

  # GET /chatrooms/1 or /chatrooms/1.json
  def show
    @messages = @chatroom.messages.ordered
  end

  # GET /chatrooms/new
  def new
    @chatroom = Chatroom.new
  end

  # GET /chatrooms/1/edit
  def edit
  end

  # POST /chatrooms or /chatrooms.json
  def create
    @chatroom = current_user.owned_chatrooms.build(chatroom_params)
    
    respond_to do |format|
      if @chatroom.save
        # once chatroom is validated and saved, create join record to make user the chatroom owner
        Participant.create!(user: current_user, chatroom: @chatroom, participation_type: "owned")

        # broadcasting from controller(instead of chatroom model) so devise current_user can be used in view... NOW ACTUALLY Using model, and switched to using multiple view files, instead of a view file with current_user based conditionals
        #@chatroom.broadcast_prepend_later_to "chatrooms", target: "owned_chatrooms", locals: {chatroom: @chatroom, current_user: current_user}
        #@chatroom.broadcast_update_to Chatroom.new, ""
        
        format.turbo_stream { flash.now[:notice] = "Chatroom was successfully created." }
        format.html { redirect_to chatrooms_url, notice: "Chatroom was successfully created." }
        
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @chatroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chatrooms/1 or /chatrooms/1.json
  def update
    respond_to do |format|
      if @chatroom.update(chatroom_params)
        # broadcasting from controller so we can send devises current_user to the view loaded via turbo stream broadcast
        @chatroom.broadcast_replace_later_to @chatroom, locals: {chatroom: @chatroom, current_user: current_user}
        format.turbo_stream { flash.now[:notice] = "Chatroom was successfully updated." }
        format.html { redirect_to chatrooms_url, notice: "Chatroom was successfully updated." }
        format.json { render :show, status: :ok, location: @chatroom }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chatroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chatrooms/1 or /chatrooms/1.json
  def destroy
    @chatroom.destroy

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Chatroom was successfully deleted." }
      format.html { redirect_to chatrooms_url, notice: "Chatroom was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  ####################################################################
    # Custom actions that aren't part of scaffolding added below #
  ####################################################################

  # POST chatrooms/search_for_users_chatrooms_path
  def search_for_users

    if params.dig(:email_search).present?
      @users = User.search_by_email(params[:email_search], @chatroom)
    else
      @users = []
    end

    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("search_for_users_results",
            partial: "chatrooms/search_for_users_results",
            locals: { users: @users, chatroom: @chatroom })
          ]
      end
    end
  end

  # PUT chatrooms/:chatroom_id/invite_to_chatroom/:user_id
  def invite_to_chatroom
    @user = User.find(params[:user_id])

    # create participation in the @chatroom for @user and set the participation_type to be "pending"
    @participation = @chatroom.participants.build(user: @user, chatroom: @chatroom, participation_type: "pending")

    respond_to do |format|
      if @participation.save
        # Now that user is invited(@participation.save), broadcast the respective chatroom with the chatroom_pending partial to the invited users list of pending chatrooms
        @chatroom.broadcast_prepend_later_to [@participation.user, "chatrooms"], target: "pending_chatrooms", partial: "chatrooms/chatroom_pending", locals: {chatroom_pending: @chatroom}
        
        format.turbo_stream { flash.now[:notice] = "User has been invited to your chatroom." }
        format.html { redirect_to chatroom_path(@chatroom), notice: "User has been invited to your chatroom." }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT chatrooms/:chatroom_id/join_chatroom
  def join_chatroom
    @chatroom = Chatroom.find(params[:chatroom_id])
     
    # find participation with current_user, the chatroom the request was made from, and where the participation_type is set to pending
    @participation = @chatroom.participants.find_by(user: current_user, chatroom: @chatroom, participation_type: "pending")

    respond_to do |format|
      if @participation.update(participation_type: 'joined')

        # Now that invited user has joined chatroom, broadcast the new user to the list of chatroom users
        @chatroom.broadcast_append_later_to [@chatroom, "users"], target: "chatroom_users", partial: "chatrooms/user", locals: {user: @participation.user}
        
        format.turbo_stream { flash.now[:notice] = "You have successfully joined the chatroom." }
        format.html { redirect_to chatrooms_path, notice: "You have successfully joined the chatroom." }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # PUT chatrooms/:chatroom_id/leave_chatroom
  def leave_chatroom
     
    # find participation with current_user, the chatroom the request was made from, and where the participation_type is set to joined
    @participation = @chatroom.participants.find_by(user: current_user, chatroom: @chatroom, participation_type: "joined")

    respond_to do |format|
      if @participation.delete

        @chatroom.broadcast_remove_to [@chatroom, "users"], target: "user_#{current_user.id}"

        format.turbo_stream { flash.now[:notice] = "You have successfully left " + @chatroom.name }
        format.html { redirect_to chatrooms_path, notice: "You have successfully joined the chatroom." }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chatroom
      if params[:chatroom_id]
        @chatroom = Chatroom.find(params[:chatroom_id])      
      else
        @chatroom = Chatroom.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def chatroom_params
      params.require(:chatroom).permit(:name, :description, :chatroom_id)
    end
end
