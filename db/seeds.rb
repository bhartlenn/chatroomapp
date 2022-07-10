# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
User.destroy_all
users = User.create([
    {
        id: 1,
        email: "bhartlenn@gmail.com",
        password: "bhartlenn"
    },
    {
        id: 2,
        email: "tester1@testers.com",
        password: "tester1"
    },
    {
        id: 3,
        email: "tester2@testers.com",
        password: "tester2"
    },
    {
        id: 4,
        email: "tester3@testers.com",
        password: "tester3"
    },
])


Chatroom.destroy_all
chatrooms = Chatroom.create([
    {
        id: 10,
        name: "Bens Chatroom",
        description: "Bens chatroom is the best chatroom ever!"
    },
    {
        id: 11,
        name: "Tester1's Chatroom",
        description: "tester1's chatroom is pretty damn cool."
    },
    {
        id: 12,
        name: "Tester2's Chatroom",
        description: "Bens chatroom is the best chatroom ever!"
    },
    {
        id: 13,
        name: "Extra Chatroom",
        description: "This chatroom is also owned by ben"
    },
])

Message.destroy_all

msgs_array = [
    "Hey how's it going? :)",
    "Great! How are you doing? :D",
    "8) Oh I'm doing awesome! Been busy having a lot of fun this summer!",
    "<8D That's so good to hear! I've been crazy busy, but having a good summer!",
    "Oh hey, how are you and the fam doing?!",

]
msgs_array.each_with_index { |msg, key|
    Message.create(
        id: key,
        content: msg,
        user_id: rand(1..2), # randomize, or follow pattern/array order?
        chatroom_id: 10
    )
}


Participant.destroy_all
participants = Participant.create([
    {
        user_id: 1,
        chatroom_id: 10,
        participation_type: 0
    },
    {
        user_id: 1,
        chatroom_id: 13,
        participation_type: 0
    },
    {
        user_id: 1,
        chatroom_id: 11,
        participation_type: 1
    },
    {
        user_id: 1,
        chatroom_id: 12,
        participation_type: 2
    },
    {
        user_id: 2,
        chatroom_id: 11,
        participation_type: 0
    },
    {
        user_id: 2,
        chatroom_id: 10,
        participation_type: 1
    },
    {
        user_id: 2,
        chatroom_id: 12,
        participation_type: 2
    },
    {
        user_id: 2,
        chatroom_id: 13,
        participation_type: 2
    },
    
    {
        user_id: 3,
        chatroom_id: 12,
        participation_type: 0
    },
    {
        user_id: 3,
        chatroom_id: 10,
        participation_type: 2
    },
    {
        user_id: 3,
        chatroom_id: 11,
        participation_type: 2
    },
    {
        user_id: 3,
        chatroom_id: 13,
        participation_type: 1
    },
])