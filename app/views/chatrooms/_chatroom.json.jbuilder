json.extract! chatroom, :id, :name, :description, :created_at, :updated_at
json.url chatroom_url(chatroom, format: :json)
