package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import b2 "vendor:box2d"
import rl "vendor:raylib"

//controls
BASE_WINDOW_WIDTH :: 2
WINDOW_WIDTH :: 1280 * BASE_WINDOW_WIDTH
WINDOW_HEIGHT :: 720 * BASE_WINDOW_WIDTH
TEXTURE_PIXELS_PER_WORLD_UNIT :: 128 //at default scale of {1,1}
SCREEN_PIXELS_PER_WORLD_UNIT: f32 : 50.0 //at initial camera zoom of 1
MAIN_FONT :: Font_Name.Lora_Variable_Font_Wght
NUM_SPRITE_RENDERING_LAYERS :: 256
NUM_SCRIPT_EXECUTION_LAYERS :: 256

cam_target := Transform{}
cam := Transform{}

//game-specific initialization logic
initialize :: proc(game: ^Game) {
	tile_spacing :: 2
	//ground
	ground_width :: 70
	for i in 0 ..= ground_width {
		obj := object_from_atlas_texture(
			game,
			atlas_textures[.Ground],
			{
				position = {
					f32(1 * i - ground_width / 2) * tile_spacing,
					-15.5 + (3 * tile_spacing * f32(i % 5)) - 0.5 * tile_spacing,
				},
				rotation = 45,
			},
		)
		add_object(game, obj)
	}

	//boxes
	num_box_rows :: 21
	for i in 0 ..< 6000 {
		x := i % num_box_rows
		y := i / num_box_rows + 2
		obj := object_from_atlas_texture(
			game,
			atlas_textures[rand.choice_enum(Texture_Name)],
			{
				position = {f32(1 * x - 10) * tile_spacing, -4.0 + tile_spacing * f32(y + 7)},
				rotation = rand.float32() * 360,
			},
			.Dynamic,
		)
		add_object(game, obj)
	}
}

//game-specific update logic
update :: proc(game: ^Game, contacts: b2.ContactEvents, dt: f32) {
	cam_speed: f32 = 1000
	cam_vel: vec2 = {0, 0}
	if rl.IsKeyDown(.W) {
		cam_vel += {0, dt}
	}
	if rl.IsKeyDown(.A) {
		cam_vel += {-dt, 0}
	}
	if rl.IsKeyDown(.S) {
		cam_vel += {0, -dt}
	}
	if rl.IsKeyDown(.D) {
		cam_vel += {dt, 0}
	}
	cam_target.position += cam_vel * cam_speed
	cam.position = math.lerp(cam.position, cam_target.position, f32(0.1))
}

//entrypoint
main :: proc() {
	game := Game{}
	init_game(&game)
	defer deinit_game(&game)
	start_game(&game)
}
