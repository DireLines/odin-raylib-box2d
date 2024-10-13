package main

import "core:fmt"
import "core:strings"
import b2 "vendor:box2d"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
tile_size: f32 : 1.0
scale: f32 : 50.0
//screen transformation
cv :: ScreenConversion{scale, tile_size, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}

convert_world_to_screen :: proc(p: b2.Vec2, cv: ScreenConversion) -> rl.Vector2 {
	return {cv.scale * p.x + 0.5 * cv.screen_width, 0.5 * cv.screen_height - cv.scale * p.y}
}

load_texture :: proc(game: ^Game, fileName: string) -> rl.Texture2D {
	texture := rl.LoadTexture(strings.clone_to_cstring(fileName))
	game.textures[fileName] = texture
	return texture
}
unload_texture :: proc(game: ^Game, fileName: string) {
	texture, ok := game.textures[fileName]
	if ok {
		rl.UnloadTexture(texture)
	}
}
draw_object :: proc(obj: ^GameObject, cv: ScreenConversion) {
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
init_game :: proc(game: ^Game) {
	game.id_generator = id_generator()
	game.window_width = WINDOW_WIDTH
	game.window_height = WINDOW_HEIGHT

	//raylib init
	rl.SetTraceLogLevel(.NONE) //shup up
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "odin+raylib+box2d game template")
	rl.SetTargetFPS(60)

	//box2d init
	game.world_id = b2.CreateWorld(b2.DefaultWorldDef())
}
deinit_game :: proc(game: ^Game) {
	b2.DestroyWorld(game.world_id)
	for _, texture in game.textures {
		rl.UnloadTexture(texture)
	}
	rl.CloseWindow()
}
add_object :: proc(game: ^Game, obj: GameObject) {
	append(&game.objects, obj)
}
initialize :: proc(game: ^Game) {
	ground_tex_file := "assets/ground.png"
	load_texture(game, ground_tex_file)
	box_tex_file := "assets/box.png"
	load_texture(game, box_tex_file)
	tile_polygon := b2.MakeSquare(0.5 * tile_size)

	for i in 0 ..< 20 {
		ground_obj := GameObject{}
		body_def := b2.DefaultBodyDef()
		body_def.position = {f32(1 * i - 10) * tile_size, -4.5 - 0.5 * tile_size}
		ground_obj.body_id = b2.CreateBody(game.world_id, body_def)
		ground_obj.image = &game.textures[ground_tex_file]
		shape_def := b2.DefaultShapeDef()
		shape_id := b2.CreatePolygonShape(ground_obj.body_id, shape_def, tile_polygon)
		add_object(game, ground_obj)
	}


	for i in 0 ..< 3 {
		box := GameObject{}
		body_def := b2.DefaultBodyDef()
		body_def.type = .dynamicBody
		body_def.position = {0, -4.0 + tile_size * f32(i + 7)}
		box.body_id = b2.CreateBody(game.world_id, body_def)
		box.image = &game.textures[box_tex_file]

		shape_def := b2.DefaultShapeDef()
		shape_def.restitution = 0.5
		shape_id := b2.CreatePolygonShape(box.body_id, shape_def, tile_polygon)
		add_object(game, box)
	}
}
start_game :: proc(game: ^Game) {
	initialize(game) //custom init logic
	pause := false
	for !rl.WindowShouldClose() {
		timer := timer()
		dt := rl.GetFrameTime()
		if rl.IsKeyPressed(rl.KeyboardKey.P) {
			pause = !pause
		}
		if !pause {
			b2.World_Step(game.world_id, dt, 8)
			contacts := b2.World_GetContactEvents(game.world_id)
			if contacts.beginCount + contacts.hitCount + contacts.endCount > 0 {
				fmt.println("contacts this frame:", contacts)
			}
			timer->time("physics")
		}

		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.DARKGRAY)

			rl.DrawText(
				"Hello, Box2D!",
				(game.window_width - rl.MeasureText("Hello Box2D", 36)) / 2,
				50,
				36,
				rl.LIGHTGRAY,
			)
			if pause {
				rl.DrawText(
					"~~paused~~",
					(game.window_width - rl.MeasureText("~~paused~~", 20)) / 2,
					100,
					20,
					rl.LIGHTGRAY,
				)
			}

			for &obj, i in game.objects {
				draw_object(&obj, cv)
			}
			timer->time("render")
		}
	}
}

main :: proc() {
	game := Game{}
	init_game(&game)
	defer deinit_game(&game)
	start_game(&game)
}
