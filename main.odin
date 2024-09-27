package main

import "core:fmt"
import b2 "vendor:box2d"
import rl "vendor:raylib"

convert_world_to_screen :: proc(p: b2.Vec2, cv: Conversion) -> rl.Vector2 {
	return {cv.scale * p.x + 0.5 * cv.screen_width, 0.5 * cv.screen_height - cv.scale * p.y}
}

draw_object :: proc(obj: ^GameObject, cv: Conversion) {
	p := b2.Body_GetWorldPoint(obj.body_id, {-0.5 * cv.tile_size, 0.5 * cv.tile_size})
	radians := b2.Body_GetRotation(obj.body_id)

	ps := convert_world_to_screen(p, cv)

	texture_scale := cv.tile_size * cv.scale / f32(obj.image.width)

	rl.DrawTextureEx(
		obj.image^,
		ps,
		-rl.RAD2DEG * b2.Rot_GetAngle(radians),
		texture_scale,
		rl.WHITE,
	)
}

main :: proc() {
	width :: 1280
	height :: 720

	rl.SetTraceLogLevel(.NONE) //shup up

	rl.InitWindow(width, height, "odin+raylib+box2d game template")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	tile_size: f32 = 1.0
	scale: f32 = 50.0

	cv := Conversion{scale, tile_size, f32(width), f32(height)}
	world_id := b2.CreateWorld(b2.DefaultWorldDef())
	defer b2.DestroyWorld(world_id)

	ground_texture := rl.LoadTexture("assets/ground.png")
	defer rl.UnloadTexture(ground_texture)
	box_texture := rl.LoadTexture("assets/box.png")
	defer rl.UnloadTexture(box_texture)

	tile_polygon := b2.MakeSquare(0.5 * tile_size)

	ground := make([]GameObject, 20)

	for &ground_obj, i in ground {
		body_def := b2.DefaultBodyDef()
		body_def.position = {f32(1 * i - 10) * tile_size, -4.5 - 0.5 * tile_size}

		ground_obj.body_id = b2.CreateBody(world_id, body_def)
		ground_obj.image = &ground_texture
		shape_def := b2.DefaultShapeDef()
		shape_id := b2.CreatePolygonShape(ground_obj.body_id, shape_def, tile_polygon)
	}

	boxes := make([]GameObject, 3)

	for &box, i in boxes {
		body_def := b2.DefaultBodyDef()
		body_def.type = .dynamicBody
		body_def.position = {0, -4.0 + tile_size * f32(i + 7)}
		box.body_id = b2.CreateBody(world_id, body_def)
		box.image = &box_texture

		shape_def := b2.DefaultShapeDef()
		shape_def.restitution = 0.5
		shape_id := b2.CreatePolygonShape(box.body_id, shape_def, tile_polygon)
	}

	pause := false

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		if rl.IsKeyPressed(rl.KeyboardKey.P) {
			pause = !pause
		}
		if !pause {
			b2.World_Step(world_id, dt, 8)
			contacts := b2.World_GetContactEvents(world_id)
			if contacts.beginCount + contacts.hitCount + contacts.endCount > 0 {
				fmt.println("contacts this frame:", contacts)
			}
		}

		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.DARKGRAY)

			rl.DrawText(
				"Hello, Box2D!",
				(width - rl.MeasureText("Hello Box2D", 36)) / 2,
				50,
				36,
				rl.LIGHTGRAY,
			)
			if pause {
				rl.DrawText(
					"~~paused~~",
					(width - rl.MeasureText("~~paused~~", 20)) / 2,
					100,
					20,
					rl.LIGHTGRAY,
				)
			}

			for &ground_obj, i in ground {
				draw_object(&ground_obj, cv)
			}

			for &box, i in boxes {
				draw_object(&box, cv)
			}
		}
	}
}
