## My ideas
- Server
  - make it easy to identify the server Window [#1](../../issues/1)
  - make the Kick Buttopn functional [#2](../../issues/2)
  
- Ingame Menu
  - Make ESC show the Menu for quitting the Game [#3](../../issues/3)
  
- Spawn
  - Different für RED and BLUE Team [#4](../../issues/4)
  
- Chat
  - Focus the input mask when opened [#5](../../issues/5)
  - Show the Playername when joining/leaving [#6](../../issues/6)
  - Make a key to show Chat [#7](../../issues/7)
  
- Fix Debug Warnings [#8](../../issues/8)



# Godot Simple Networking

A simple networking base template you can use in your Godot project.
It allows to connect to a local server by setting his IP address, the client spawn a player on the spawn node, the position of each player is updated and their username is displayed on top. The active player the client controls is highlighted and his name colored. It has a simple chat system that also displays who has connected you can use it by pressing Enter. By holding Tab you can display the connected players.

It has a single script and scene for the networking, chatting system and to display the connected players. You just have to instance your map and set the player scene in the script and in the MultiplayerSpawner. You must also set a path to the SpawnPosition of the MultiplayerSpawner.

To use it more easily you can open automatically multiple instances of the game in Debug > Run Multiples Instances, then choose how many instances.
