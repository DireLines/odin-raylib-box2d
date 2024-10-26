package main

import "core:fmt"
import "core:math"
import b2 "vendor:box2d"
import rl "vendor:raylib"

// manual procs for constructing objects

physical_obj_from_atlas_texture :: proc(
	game: ^Game,
	texture: Atlas_Texture,
	transform: Transform,
	body_type: b2.BodyType = .staticBody,
) -> GameObject {
	scale := transform.scale
	//zero value does not make sense here - assume you meant normal scale
	if scale == {0, 0} {
		scale = {1, 1}
	}
	obj := GameObject{}
	body_def := b2.DefaultBodyDef()
	body_def.type = body_type
	body_def.position = transform.position
	rot := rl.DEG2RAD * transform.rotation
	body_def.rotation = {
		s = math.sin(rot),
		c = math.cos(rot),
	}
	body_id := b2.CreateBody(game.world_id, body_def)
	obj.body_info = BodyHandle {
		id    = body_id,
		scale = scale,
	}
	obj.sprite.texture = texture
	obj.sprite.color = rl.WHITE
	shape_def := b2.DefaultShapeDef()
	box_dim: vec2 =
		{texture.rect.width * scale.x, texture.rect.height * scale.y} * (0.5 / PIXELS_PER_TILE)
	tile_polygon := b2.MakeBox(box_dim.x, box_dim.y)
	shape_id := b2.CreatePolygonShape(body_id, shape_def, tile_polygon)
	return obj
}

display_obj_from_atlas_texture :: proc(
	game: ^Game,
	transform: Transform,
	texture: Atlas_Texture,
) -> GameObject {
	scale := transform.scale
	//zero value does not make sense here - assume you meant normal scale
	if scale == {0, 0} {
		scale = {1, 1}
	}
	obj := GameObject{}
	obj.sprite.texture = texture
	obj.sprite.color = rl.WHITE
	box_dim: vec2 =
		{texture.rect.width * transform.scale.x, texture.rect.height * transform.scale.y} /
		PIXELS_PER_TILE
	obj.body_info = Transform {
		position = transform.position,
		rotation = transform.rotation,
		scale    = scale,
		pivot    = {-box_dim.x / 2, box_dim.y / 2},
	}
	return obj
}
