class Message < ApplicationRecord
  belongs_to :user
  
  belongs_to :chatroom

  validates :content, presence: true

  scope :ordered, -> { order(id: :asc) }

  #after_create_commit -> { broadcast_append_later_to "chatroom_messages", partial: "messages/message", locals: {message: self}, target: "chatroom_messages" }

  #broadcasts_to ->(message) {[ message.chatroom, "messages" ]}, inserts_by: :append, target: "chatroom_messages"
end
