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

RenderLayer :: enum i8 {
	Default = 0,
	Lowest  = -128,
	Highest = 127,
}

Game :: struct {
	window_width:  i32,
	window_height: i32,
	objects:       #soa[dynamic]GameObject,
	textures:      map[string]rl.Texture,
	fonts:         map[Font_Name]rl.Font,
	scripts:       [NUM_SCRIPT_EXECUTION_LAYERS][dynamic]GameObjectId,
	render_layers: [NUM_SPRITE_RENDERING_LAYERS][dynamic]GameObjectId,
	start_tick:    time.Tick,
	frame_counter: u64,
	world_id:      b2.WorldId,
	paused:        bool,
}

Transform :: struct {
	position: vec2, //position of the CENTER of the object
	rotation: f32, //DEGREES, not radians
	scale:    vec2, //multipliers on the x and y dims of the texture when rendering or for physics
	pivot:    vec2,
}

BodyHandle :: struct {
	id:    b2.BodyId,
	scale: vec2,
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
	body_info:     union {
		BodyHandle, //box2d handle - box2d handles transform for physics simulated objects
		Transform, //we handle transform for other objects
	},
	sprite:        Sprite,
	script:        Script,
}
SpriteTexture :: union {
	rl.Texture,
	Atlas_Texture,
}
Sprite :: struct {
	file:    string,
	layer:   i8, //rendering order
	color:   rl.Color,
	texture: SpriteTexture,
}

Script :: struct {
	execution_layer:    i8, //execution order
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
