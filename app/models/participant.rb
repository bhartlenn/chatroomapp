class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom

  attribute :participation_type, :integer, default: 0
  enum participation_type: {
    owned: 0,
    pending: 1,
    joined: 2,
    banned: 3
  }

  #after_update_commit -> { broadcast_prepend_later_to "chatrooms", partial: "chatrooms/chatroom", locals: {chatroom: self.chatroom}, target: "joined_chatrooms" }

end
