package main

import "core:fmt"
import b2 "vendor:box2d"
import rl "vendor:raylib"

BASE_WINDOW_WIDTH :: 2
WINDOW_WIDTH :: 1280 * BASE_WINDOW_WIDTH
WINDOW_HEIGHT :: 720 * BASE_WINDOW_WIDTH
tile_size: f32 : 1.0
scale: f32 : 10.0
//screen transformation
cv :: ScreenConversion{scale, tile_size, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}

initialize :: proc(game: ^Game) {
	tile_polygon := b2.MakeSquare(0.5 * tile_size)

	//ground
	ground_width :: 70
	for i in 0 ..= ground_width {
		obj := GameObject{}
		body_def := b2.DefaultBodyDef()
		body_def.position = {
			f32(1 * i - ground_width / 2) * tile_size,
			-15.5 + (3 * tile_size * f32(i % 5)) - 0.5 * tile_size,
		}
		obj.body_id = b2.CreateBody(game.world_id, body_def)
		obj.sprite.image = get_texture(game, "assets/ground.png")
		obj.sprite.color = rl.WHITE
		shape_def := b2.DefaultShapeDef()
		shape_id := b2.CreatePolygonShape(obj.body_id, shape_def, tile_polygon)
		add_object(game, obj)
	}

	//boxes
	num_box_rows :: 21
	for i in 0 ..< 3000 {
		x := i % num_box_rows
		y := i / num_box_rows + 2
		obj := GameObject{}
		body_def := b2.DefaultBodyDef()
		body_def.type = .dynamicBody
		body_def.position = {f32(1 * x - 10) * tile_size, -4.0 + tile_size * f32(y + 7)}
		obj.body_id = b2.CreateBody(game.world_id, body_def)
		obj.sprite.image = get_texture(game, "assets/box.png")
		obj.sprite.color = rl.WHITE
		shape_def := b2.DefaultShapeDef()
		shape_def.restitution = 0.01
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
