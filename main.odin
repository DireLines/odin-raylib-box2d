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
player: GameObject

//game-specific initialization logic
initialize :: proc(game: ^Game) {
	player = object_from_atlas_texture(
		game,
		atlas_textures[.Puzzle_Piece_100],
		{position = {0, 0}},
		.Dynamic,
	)
	add_object(game, player)
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
			atlas_textures[.Box],
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
	player_speed: f32 = 10
	player_movement: vec2 = {0, 0}
	if rl.IsKeyDown(.W) {
		player_movement += {0, dt}
	}
	if rl.IsKeyDown(.A) {
		player_movement += {-dt, 0}
	}
	if rl.IsKeyDown(.S) {
		player_movement += {0, -dt}
	}
	if rl.IsKeyDown(.D) {
		player_movement += {dt, 0}
	}
	player_pos := get_object_pos(player)
	set_object_pos(player, player_pos + player_movement * player_speed)
	cam_target.position = player_pos * SCREEN_PIXELS_PER_WORLD_UNIT
	cam.position = math.lerp(cam.position, cam_target.position, f32(0.16))
}

//entrypoint
main :: proc() {
	game := Game{}
	init_game(&game)
	defer deinit_game(&game)
	start_game(&game)
}
