extends Node

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")
var player_container = preload("res://ui/player_container.tscn")

var playerdata : Dictionary = { "Team_Blue": {}, "Team_Red": {} }

var playernode: Node
var mapnode: Node
var rootnode: Node
var spawnrootnode: Node
