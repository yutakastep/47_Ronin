extends Resource
class_name RoomData
@export var start : bool = false
@export var end : bool = false
@export var left : bool = false
@export var right : bool = false
@export var top : bool = false
@export var bottom : bool = false
@export var section : String
@export var keyword : String = "Placeholder"
@export var x : int = -1
@export var y : int = -1
@export var associated_room : Array[String] = []
