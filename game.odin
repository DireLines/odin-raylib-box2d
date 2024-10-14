package main

import "core:fmt"
import "core:strings"
import b2 "vendor:box2d"
import rl "vendor:raylib"

convert_world_to_screen :: proc(p: b2.Vec2, cv: ScreenConversion) -> rl.Vector2 {
	return {cv.scale * p.x + 0.5 * cv.screen_width, 0.5 * cv.screen_height - cv.scale * p.y}
}
get_texture :: proc(game: ^Game, filename: string) -> rl.Texture2D {
	texture, ok := game.textures[filename]
	if ok {
		return texture
	}
	return load_texture(game, filename)
}
load_texture :: proc(game: ^Game, filename: string) -> rl.Texture2D {
	texture := rl.LoadTexture(strings.clone_to_cstring(filename))
	game.textures[filename] = texture
	return texture
}
unload_texture :: proc(game: ^Game, filename: string) {
	texture, ok := game.textures[filename]
	if ok {
		rl.UnloadTexture(texture)
	}
}
draw_object :: proc(obj: GameObject) {
	p := b2.Body_GetWorldPoint(obj.body_id, {-0.5 * cv.tile_size, 0.5 * cv.tile_size})
	radians := b2.Body_GetRotation(obj.body_id)

	ps := convert_world_to_screen(p, cv)

	texture_scale := cv.tile_size * cv.scale / f32(obj.sprite.image.width)
	rl.DrawTextureEx(
		obj.sprite.image,
		ps,
		-rl.RAD2DEG * b2.Rot_GetAngle(radians),
		texture_scale,
		obj.sprite.color,
	)
}
init_game :: proc(game: ^Game) {
	game.window_width = WINDOW_WIDTH
	game.window_height = WINDOW_HEIGHT
	game.objects = make_soa(#soa[dynamic]GameObject)

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
	append_soa(&game.objects, obj)
}

render :: proc(game: ^Game) {
	timer := timer()
	rl.BeginDrawing()
	defer rl.EndDrawing()
	darkgray := rl.Color{32, 32, 30, 255}
	rl.ClearBackground(darkgray)
	for &obj in game.objects {
		draw_object(obj)
	}
	if game.paused {
		rl.DrawText(
			"~~paused~~",
			(game.window_width - rl.MeasureText("~~paused~~", 20)) / 2,
			100,
			20,
			rl.LIGHTGRAY,
		)
	}
	timer->time("render")
}

start_game :: proc(game: ^Game) {
	initialize(game) //custom init logic
	for !rl.WindowShouldClose() {
		timer := timer()
		dt := rl.GetFrameTime()
		if rl.IsKeyPressed(rl.KeyboardKey.P) {
			game.paused = !game.paused
		}
		if !game.paused {
			b2.World_Step(game.world_id, dt, 8)
			contacts := b2.World_GetContactEvents(game.world_id)
			timer->time("physics")
			// if contacts.beginCount + contacts.hitCount + contacts.endCount > 0 {
			// 	fmt.println("contacts this frame:", contacts)
			// }
		}
		render(game)
	}
}
