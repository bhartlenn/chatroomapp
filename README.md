# README

The chatroomapp is a rails 7 app I developed on my own to explore and better learn about implementing Rails 7's new HotWire features. 

Users can register an account and login with the Devise gem. Then create a chatroom without page reloading using turbo frames. When viewing any of their chatrooms a chatroom owner can search for users to invite to their chatroom. 

Invited users will see a chatroom invitation popup in their list of chatroom invites. If they click on accept invite, the chatroom will be moved to the joined chatrooms section of their chatrooms index page using turbo streams.

Chatroom messages are broadcasted to all participants of a chatroom.

Chatroom messages can be deleted and all chatroom participants will see message removed.

* Rails version: 7.0.2.4

* Ruby version: 3.0.0

* ...
