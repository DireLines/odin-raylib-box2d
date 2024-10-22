package main

import b2 "vendor:box2d"
import rl "vendor:raylib"

// manual procs for constructing objects

make_ground_obj :: proc(game: ^Game, pos: vec2) -> GameObject {
	obj := GameObject{}
	tex := atlas_textures[.Ground]
	body_def := b2.DefaultBodyDef()
	body_def.position = pos
	body_id := b2.CreateBody(game.world_id, body_def)
	obj.body_info = body_id
	obj.sprite.texture = tex
	obj.sprite.color = rl.WHITE
	shape_def := b2.DefaultShapeDef()
	box_dim: vec2 = {tex.rect.width, tex.rect.height} * (0.5 / PIXELS_PER_TILE)
	tile_polygon := b2.MakeBox(box_dim.x, box_dim.y)
	shape_id := b2.CreatePolygonShape(body_id, shape_def, tile_polygon)
	return obj
}
make_physical_obj_from_tex :: proc(game: ^Game, pos: vec2, tex: Atlas_Texture) -> GameObject {
	obj := GameObject{}
	body_def := b2.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.position = pos
	body_id := b2.CreateBody(game.world_id, body_def)
	obj.body_info = body_id
	obj.sprite.texture = tex
	obj.sprite.color = rl.WHITE
	shape_def := b2.DefaultShapeDef()
	shape_def.restitution = 0.01
	box_dim: vec2 = {tex.rect.width, tex.rect.height} * (0.5 / PIXELS_PER_TILE)
	tile_polygon := b2.MakeBox(box_dim.x, box_dim.y)
	shape_id := b2.CreatePolygonShape(body_id, shape_def, tile_polygon)
	return obj
}

make_display_obj_from_tex :: proc(game: ^Game, pos: vec2, tex: Atlas_Texture) -> GameObject {
	obj := GameObject{}
	obj.sprite.texture = tex
	obj.sprite.color = rl.WHITE
	box_dim: vec2 = {tex.rect.width, tex.rect.height} / PIXELS_PER_TILE
	obj.body_info = Transform {
		position = pos,
		scale    = box_dim,
		pivot    = {-box_dim.x / 2, box_dim.y / 2},
	}
	return obj
}
