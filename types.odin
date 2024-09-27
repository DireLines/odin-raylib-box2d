package main

import "core:time"

import b2 "vendor:box2d"
import rl "vendor:raylib"
vec2 :: [2]f32
mat3 :: matrix[3, 3]f32


Conversion :: struct {
	scale:         f32,
	tile_size:     f32,
	screen_width:  f32,
	screen_height: f32,
}

Game :: struct {
	id_generator:  IDGenerator,
	window_width:  i32,
	window_height: i32,
	objects:       [dynamic]GameObject,
	systems:       [dynamic]^System,
	textures:      map[string]rl.Texture,
	start_tick:    time.Tick,
	frame_counter: u64,
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

GameObject :: struct {
	name:          string,
	component_set: bit_set[Component],
	parent:        ^GameObject,
	children:      [dynamic]^GameObject,
	body_id:       b2.BodyId,
	using sprite:  Sprite,
	using script:  Script,
}


Transform :: struct {
	position: vec2,
	scale:    vec2,
	pivot:    vec2,
	rotation: f32,
}

Rigidbody :: struct {
	mass:              f32,
	moment_of_inertia: f32,
	velocity:          vec2,
	angular_velocity:  f32,
	force:             vec2,
	torque:            f32,
}

Sprite :: struct {
	file:  string,
	z:     f32, // rendering order
	color: rl.Color,
	image: ^rl.Texture,
}
Script :: struct {
	awake:              proc(self_index: int, game: ^Game),
	start:              proc(self_index: int, game: ^Game),
	update:             proc(self_index: int, game: ^Game),
	on_collision_enter: proc(self_index: int, other_index: int, game: ^Game),
	on_collision_stay:  proc(self_index: int, other_index: int, game: ^Game),
	on_collision_exit:  proc(self_index: int, other_index: int, game: ^Game),
}


IDGenerator :: struct {
	id:   int,
	next: proc(_: ^IDGenerator) -> int,
}
id_generator :: proc() -> IDGenerator {
	return IDGenerator{id = 0, next = proc(gen: ^IDGenerator) -> int {
			gen.id += 1
			return gen.id
		}}
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
