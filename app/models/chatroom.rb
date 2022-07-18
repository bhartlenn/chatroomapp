class Chatroom < ApplicationRecord

    has_many :participants, dependent: :destroy
    has_many :users, through: :participants 

    has_many :messages, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    def owner
        participants_of_type('owned').first
    end
    
    def joined_users
        participants_of_type('joined')
    end

    def all_users_not_pending
        participants_not_of_type('pending')
    end

    scope :ordered, -> { order(id: :asc) }

    # Examples of broadcasting from rails model:
    # full version with all properties set as default values would be like the next 3 lines, see below for short form version of the three lines below  
    #after_create_commit -> { broadcast_prepend_later_to "chatrooms", partial: "chatrooms/chatroom", locals: {chatroom: self}, target: "chatrooms" }
    #after_update_commit -> { broadcast_replace_later_to "chatrooms", partial: "chatrooms/chatroom", locals: {chatroom: self}, target: "chatrooms" }
    #after_destroy_commit -> { broadcast_remove_to "chatrooms" }
    
    # The above three callbacks are equivalent to the following single line, though the above may be beneficial where greater control is needed
    #broadcasts_to ->(chatroom) { [@participation.user, "chatrooms"] }, inserts_by: :prepend


    private
    def participants_of_type(types)
        users.where participants: { participation_type: types } 
    end
    def participants_not_of_type(types)
        users.where.not participants: { participation_type: types } 
    end
end
