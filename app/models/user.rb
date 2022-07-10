class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :participants, dependent: :destroy
  has_many :chatrooms, through: :participants

  has_many :messages

  def owned_chatrooms
    chatrooms_of_type('owned')
  end
  
  def joined_chatrooms
    chatrooms_of_type('joined')
  end

  def pending_chatrooms
    chatrooms_of_type('pending')
  end

  def username
    "@" + email.split("@").first
  end

  def is_chatroom_owner?(chatroom)
    chatrooms.where(participants: { participation_type: "owned" } ).include?(chatroom)
  end
  
  def has_joined_chatroom?(chatroom)
    chatrooms.where(participants: { participation_type: "joined" } ).include?(chatroom)
  end
  
  # used by chatroom#search_for_users
  scope :search_by_email, -> (email, chatroom) { where('email LIKE ?', "%#{email}%").where.not(id: Participant.distinct.select(:user_id).where(chatroom: chatroom)).order(created_at: :asc) }

  private
  def chatrooms_of_type(type)
    chatrooms.where participants: { participation_type: type } 
  end
  
end
