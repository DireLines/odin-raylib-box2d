package main

import "core:time"

import b2 "vendor:box2d"
import rl "vendor:raylib"
vec2 :: [2]f32
mat3 :: matrix[3, 3]f32
Rect :: rl.Rectangle

ScreenConversion :: struct {
	scale:         f32,
	screen_width:  f32,
	screen_height: f32,
}

Game :: struct {
	window_width:  i32,
	window_height: i32,
	objects:       #soa[dynamic]GameObject,
	textures:      map[string]rl.Texture,
	start_tick:    time.Tick,
	frame_counter: u64,
	world_id:      b2.WorldId,
	paused:        bool,
}

Component :: enum {
	Transform,
	Rigidbody,
	Collider,
	Sprite,
	Animation,
	Script,
	Children,
}
GameObjectId :: distinct uint
GameObject :: struct {
	name:          string,
	component_set: bit_set[Component],
	parent:        Maybe(GameObjectId),
	children:      []GameObjectId,
	body_id:       b2.BodyId, //box2d handle - box2d handles transform / physics
	sprite:        Sprite,
	script:        Script,
}
SpriteTexture :: union {
	rl.Texture,
	Atlas_Texture,
}
Sprite :: struct {
	file:    string,
	z:       f32, // rendering order
	color:   rl.Color,
	texture: SpriteTexture,
}
Script :: struct {
	awake:              proc(self_index: int, game: ^Game),
	start:              proc(self_index: int, game: ^Game),
	update:             proc(self_index: int, game: ^Game),
	on_collision_enter: proc(self_index: int, other_index: int, game: ^Game),
	on_collision_stay:  proc(self_index: int, other_index: int, game: ^Game),
	on_collision_exit:  proc(self_index: int, other_index: int, game: ^Game),
}

System :: struct {
	name:              string,
	components_needed: bit_set[Component],
	start:             proc(system: ^System, game: ^Game),
	update:            proc(system: ^System, game: ^Game),
	needObject:        proc(system: ^System, game: ^Game, obj_index: int) -> bool,
	addObject:         proc(system: ^System, game: ^Game, obj_index: int),
	removeObject:      proc(system: ^System, game: ^Game, obj_index: int),
}
