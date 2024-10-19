package main

import "core:fmt"
import "core:slice"
import "core:strings"
import b2 "vendor:box2d"
import rl "vendor:raylib"


// This loads atlas.png (generated by the atlas builder) at compile time and stores it in the
// executable, the type of this constant will be `[]u8`. I.e. a slice of bytes. This means that you
// don't need atlas.png next to your game after compilation. It will live in the executable. When
// the executable starts it loads a raylib texture from this data.
ATLAS_DATA :: #load("atlas.png")
// This is loaded in `main` from `ATLAS_DATA`
atlas: rl.Texture


convert_world_to_screen :: proc(p: b2.Vec2, cv: ScreenConversion) -> rl.Vector2 {
	return {cv.scale * p.x + 0.5 * cv.screen_width, 0.5 * cv.screen_height - cv.scale * p.y}
}
draw_object :: proc(obj: GameObject) {
	b2_size: vec2
	switch tex in obj.sprite.texture {
	case Atlas_Texture:
		b2_size = {tex.rect.width, tex.rect.height} / PIXELS_PER_TILE
	case rl.Texture:
		b2_size = {f32(tex.width), f32(tex.height)} / PIXELS_PER_TILE
	}
	p := b2.Body_GetWorldPoint(obj.body_id, {-0.5 * b2_size.x, 0.5 * b2_size.y})
	radians := b2.Body_GetRotation(obj.body_id)

	ps := convert_world_to_screen(p, cv)

	switch tex in obj.sprite.texture {
	case Atlas_Texture:
		source := tex.rect
		texture_scale := cv.scale / PIXELS_PER_TILE
		dest := Rect{ps.x, ps.y, source.width * texture_scale, source.height * texture_scale}
		rl.DrawTexturePro(
			atlas,
			source,
			dest,
			{0, 0},
			-rl.RAD2DEG * b2.Rot_GetAngle(radians),
			obj.sprite.color,
		)
	case rl.Texture:
		texture_scale := cv.scale / PIXELS_PER_TILE
		rl.DrawTextureEx(
			tex,
			ps,
			-rl.RAD2DEG * b2.Rot_GetAngle(radians),
			texture_scale,
			obj.sprite.color,
		)
	}

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
init_game :: proc(game: ^Game) {
	game.window_width = WINDOW_WIDTH
	game.window_height = WINDOW_HEIGHT
	game.objects = make_soa(#soa[dynamic]GameObject)

	//raylib init
	rl.SetTraceLogLevel(.NONE) //shup up
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "odin+raylib+box2d game template")
	rl.SetTargetFPS(60)
	rl.SetConfigFlags({.WINDOW_RESIZABLE})

	// Load atlas from ATLAS_DATA, which was stored in the executable at compile-time.
	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)
	// Set the shapes drawing texture, this makes rl.DrawRectangleRec etc use the atlas
	rl.SetShapesTexture(atlas, SHAPES_TEXTURE_RECT)
	game.font = load_atlased_font(.Inconsolata_Regular)

	//box2d init
	game.world_id = b2.CreateWorld(b2.DefaultWorldDef())
}
deinit_game :: proc(game: ^Game) {
	b2.DestroyWorld(game.world_id)
	rl.UnloadTexture(atlas)
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
		font_size :: ATLAS_FONT_SIZE * 2
		rl.DrawTextEx(
			game.font,
			"~~paused~~",
			{f32((game.window_width - rl.MeasureText("~~paused~~", font_size)) / 2), 100},
			font_size,
			0,
			rl.WHITE,
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
			num_contacts := contacts.beginCount + contacts.hitCount + contacts.endCount
			// if num_contacts > 0 {
			// 	fmt.println("num contacts this frame:", num_contacts)
			// }
		}
		render(game)
	}
}


// TODO: make atlas_builder handle multiple fonts, and this takes a font name
// This uses the letters in the atlas to create a raylib font. Since this font is in the atlas
// it can be drawn in the same draw call as the other graphics in the atlas. Don't use
// rl.UnloadFont() to destroy this font, instead use `delete_atlased_font`, since we've set up the
// memory ourselves.
//
// The set of available glyphs is governed by `LETTERS_IN_FONT` in `atlas_builder.odin`
// The font used is governed by `FONT_FILENAME` in `atlas_builder.odin`
load_atlased_font :: proc(font_name: Atlas_Font_Name) -> rl.Font {
	num_glyphs := len(LETTERS_IN_FONT)
	font_rects := make([]Rect, num_glyphs)
	glyphs := make([]rl.GlyphInfo, num_glyphs)

	for ag, idx in atlas_fonts[font_name] {
		font_rects[idx] = ag.rect
		glyphs[idx] = {
			value    = ag.value,
			offsetX  = i32(ag.offset_x),
			offsetY  = i32(ag.offset_y),
			advanceX = i32(ag.advance_x),
		}
	}

	return {
		baseSize = ATLAS_FONT_SIZE,
		glyphCount = i32(num_glyphs),
		glyphPadding = 0,
		texture = atlas,
		recs = raw_data(font_rects),
		glyphs = raw_data(glyphs),
	}
}
delete_atlased_font :: proc(font: rl.Font) {
	delete(slice.from_ptr(font.glyphs, int(font.glyphCount)))
	delete(slice.from_ptr(font.recs, int(font.glyphCount)))
}
