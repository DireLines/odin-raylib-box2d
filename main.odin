package main

import "core:fmt"
import "core:math/rand"
import b2 "vendor:box2d"
import rl "vendor:raylib"

//controls
BASE_WINDOW_WIDTH :: 1
WINDOW_WIDTH :: 1280 * BASE_WINDOW_WIDTH
WINDOW_HEIGHT :: 720 * BASE_WINDOW_WIDTH
PIXELS_PER_TILE :: 128
TILE_SCALE: f32 : 30.0
MAIN_FONT :: Font_Name.Lora_Variable_Font_Wght
NUM_SPRITE_RENDERING_LAYERS :: 256
NUM_SCRIPT_EXECUTION_LAYERS :: 256

//screen transformation
cv :: ScreenConversion{TILE_SCALE, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}

//game-specific initialization logic
initialize :: proc(game: ^Game) {
	tile_spacing :: 2
	//ground
	ground_width :: 70
	for i in 0 ..= ground_width {
		obj := display_obj_from_atlas_texture(
			game,
			atlas_textures[.Ground],
			{
				position = {
					f32(1 * i - ground_width / 2) * tile_spacing,
					-15.5 + (3 * tile_spacing * f32(i % 5)) - 0.5 * tile_spacing,
				},
				rotation = 45,
				scale = {1, 2},
			},
		)
		obj.sprite.color = rl.DARKBROWN
		phys := physical_obj_from_atlas_texture(
			game,
			atlas_textures[.Ground],
			{
				position = {
					f32(1 * i - ground_width / 2) * tile_spacing,
					-15.5 + (3 * tile_spacing * f32(i % 5)) - 0.5 * tile_spacing,
				},
				rotation = 45,
				scale = {1, 2},
			},
		)
		add_object(game, obj)
		add_object(game, phys)
	}

	//boxes
	num_box_rows :: 21
	for i in 0 ..< 6000 {
		x := i % num_box_rows
		y := i / num_box_rows + 2
		obj := physical_obj_from_atlas_texture(
			game,
			atlas_textures[.Box],
			{position = {f32(1 * x - 10) * tile_spacing, -4.0 + tile_spacing * f32(y + 7)}},
			.dynamicBody,
		)
		add_object(game, obj)
	}
}

//entrypoint
main :: proc() {
	game := Game{}
	init_game(&game)
	defer deinit_game(&game)
	start_game(&game)
}
