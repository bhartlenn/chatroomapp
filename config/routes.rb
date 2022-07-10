Rails.application.routes.draw do
  # home page route handled in pages controller
  get 'pages/home'

  devise_scope :user do
    # Redirests signing out users back to sign-in
    get "users", to: "devise/sessions#new"
  end
  devise_for :users

  resources :chatrooms do
    # When user views a chatroom, need to be able to search for users to invite
    post :search_for_users
    # chatroom owners can search for users(above), then click on a link to invite user to their chatroom
    put 'invite_to_chatroom/:user_id', to: 'chatrooms#invite_to_chatroom', as: 'invite'
    # When a user has a pending chatroom.participant entry, they can accept the invitation to join the chatroom
    put 'join_chatroom', to: 'chatrooms#join_chatroom', as: 'join'
    # When a user is tired of some dramatic bullshit going on in a chatroom, they can leave that shitty chatroom
    put 'leave_chatroom', to: 'chatrooms#leave_chatroom', as: 'leave'

    # no index action needed because it's on chatroom/show view, 
    # no show action needed because it wouldn't make sense for message to be shown outside chatroom
    resources :messages, except: [:index, :show]

  end

  # Defines the root path route ("/")
  root "pages#home"
  
end
