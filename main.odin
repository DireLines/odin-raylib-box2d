package main

import "core:fmt"
import "core:math/rand"
import b2 "vendor:box2d"
import rl "vendor:raylib"

BASE_WINDOW_WIDTH :: 2
WINDOW_WIDTH :: 1280 * BASE_WINDOW_WIDTH
WINDOW_HEIGHT :: 720 * BASE_WINDOW_WIDTH
PIXELS_PER_TILE :: 128
TILE_SCALE: f32 : 30.0
MAIN_FONT :: Font_Name.Atkinson_Hyperlegible_Italic
//screen transformation
cv :: ScreenConversion{TILE_SCALE, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}

initialize :: proc(game: ^Game) {
	tile_spacing :: 1.5
	//ground
	ground_width :: 70
	for i in 0 ..= ground_width {
		obj := GameObject{}
		tex := atlas_textures[.Ground]
		body_def := b2.DefaultBodyDef()
		body_def.position = {
			f32(1 * i - ground_width / 2) * tile_spacing,
			-15.5 + (3 * tile_spacing * f32(i % 5)) - 0.5 * tile_spacing,
		}
		obj.body_id = b2.CreateBody(game.world_id, body_def)
		obj.sprite.texture = tex
		obj.sprite.color = rl.WHITE
		shape_def := b2.DefaultShapeDef()
		box_dim: vec2 = {tex.rect.width, tex.rect.height} * (0.5 / PIXELS_PER_TILE)
		tile_polygon := b2.MakeBox(box_dim.x, box_dim.y)
		shape_id := b2.CreatePolygonShape(obj.body_id, shape_def, tile_polygon)
		add_object(game, obj)
	}

	//boxes
	num_box_rows :: 21
	for i in 0 ..< 6000 {
		x := i % num_box_rows
		y := i / num_box_rows + 2
		tex := atlas_textures[rand.choice_enum(Texture_Name)]
		obj := GameObject{}
		body_def := b2.DefaultBodyDef()
		body_def.type = .dynamicBody
		body_def.position = {f32(1 * x - 10) * tile_spacing, -4.0 + tile_spacing * f32(y + 7)}
		obj.body_id = b2.CreateBody(game.world_id, body_def)
		obj.sprite.texture = tex
		obj.sprite.color = rl.WHITE
		shape_def := b2.DefaultShapeDef()
		shape_def.restitution = 0.01
		box_dim: vec2 = {tex.rect.width, tex.rect.height} * (0.5 / PIXELS_PER_TILE)
		tile_polygon := b2.MakeBox(box_dim.x, box_dim.y)
		shape_id := b2.CreatePolygonShape(obj.body_id, shape_def, tile_polygon)
		add_object(game, obj)
	}
}
main :: proc() {
	game := Game{}
	init_game(&game)
	defer deinit_game(&game)
	start_game(&game)
}
