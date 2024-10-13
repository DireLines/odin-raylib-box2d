package main

// import "core:fmt"
// import "core:math"
// import glm "core:math/linalg/glsl"
// import "core:slice"
// import "core:strings"
// import "core:time"
// import b2 "vendor:box2d"
// import rl "vendor:raylib"

// has_desired_components :: proc(obj: ^GameObject, desired_components: bit_set[Component]) -> bool {
// 	return (obj.component_set & desired_components) == desired_components
// }


// test_system :: proc() -> System {
// 	return System{name = "system", start = proc(system: ^System, game: ^Game) {
// 			fmt.println("start")
// 		}, update = proc(system: ^System, game: ^Game) {
// 			fmt.println("update")
// 		}, needObject = proc(system: ^System, game: ^Game, obj_index: int) -> bool {
// 			return true
// 		}, addObject = proc(system: ^System, game: ^Game, obj_index: int) {
// 			obj := game.objects[obj_index]
// 			fmt.println("object added:", obj.name)
// 		}, removeObject = proc(system: ^System, game: ^Game, obj_index: int) {
// 			obj := game.objects[obj_index]
// 			fmt.println("object removed:", obj.name)
// 		}}
// }

// script_runner :: proc() -> System {
// 	return System {
// 		name = "ScriptRunner",
// 		components_needed = {.Script},
// 		start = proc(system: ^System, game: ^Game) {
// 		},
// 		update = proc(system: ^System, game: ^Game) {
// 			for &obj, ind in game.objects {
// 				if !system->needObject(game, ind) {
// 					continue
// 				}
// 				s := obj.script
// 				s.update(ind, game)
// 			}
// 		},
// 		needObject = proc(system: ^System, game: ^Game, obj_index: int) -> bool {
// 			obj := game.objects[obj_index]
// 			return has_desired_components(&obj, system.components_needed)
// 		},
// 		addObject = proc(system: ^System, game: ^Game, obj_index: int) {
// 			s := game.objects[obj_index].script
// 			s.awake(obj_index, game)
// 			s.start(obj_index, game)
// 		},
// 		removeObject = proc(system: ^System, game: ^Game, obj_index: int) {

// 		},
// 	}
// }

// sprite_render_order: [dynamic]int
// renderer :: proc() -> System {
// 	mat_vec_mul :: proc(m: glm.mat3, v: glm.vec2) -> glm.vec2 {
// 		return {v.x * m[0, 0] + v.y * m[0, 1] + m[0, 2], v.x * m[1, 0] + v.y * m[1, 1] + m[1, 2]}
// 	}
// 	darkgray :: rl.Color{32, 32, 30, 255}
// 	renderer_update :: proc(system: ^System, using game: ^Game) {
// 		timer := timer()
// 		rl.BeginDrawing();defer rl.EndDrawing()
// 		rl.ClearBackground(darkgray)
// 		timer->time("clear")
// 		context.user_ptr = game
// 		z_less :: proc(a, b: int) -> bool {
// 			game := (^Game)(context.user_ptr)
// 			return game.objects[a].sprite.z < game.objects[b].sprite.z
// 		}
// 		if game.frame_counter == 0 {
// 			//first frame - unstable sort is way faster
// 			slice.sort_by(sprite_render_order[:], z_less)
// 		} else {
// 			//stable sort is still fast if nearly sorted to begin with and looks nicer
// 			slice.stable_sort_by(sprite_render_order[:], z_less)
// 		}
// 		timer->time("sort")
// 		center := transform.translate(f32(game.window_width / 2), f32(game.window_height / 2))
// 		//TODO: add camera transform here
// 		cam_t := center
// 		for index in sprite_render_order {
// 			t := &game.objects[index].transform
// 			s := &game.objects[index].sprite
// 			disp_transform := cam_t * transform.apply(t) * transform.unpivot(t)
// 			pos := mat_vec_mul(disp_transform, {0, 0})
// 			rl.DrawTextureEx(
// 				texture = s.image^,
// 				position = {pos.x, pos.y},
// 				rotation = math.to_degrees(t.rotation),
// 				scale = t.scale.x, //TODO: change to draw call with independent x/y scaling
// 				tint = s.color,
// 			)
// 		}
// 		timer->time("draw")
// 	}
// 	addObject :: proc(system: ^System, game: ^Game, obj_index: int) {
// 		obj_file := game.objects[obj_index].file
// 		texture := add_sprite(game, obj_file)
// 		game.objects[obj_index].image = texture
// 		// //TODO: figure out how to not set this
// 		game.objects[obj_index].pivot = {f32(texture.width / 2), f32(texture.height / 2)}
// 		append(&sprite_render_order, obj_index)
// 	}
// 	return System {
// 		name = "Renderer",
// 		components_needed = {.Transform, .Sprite},
// 		start = proc(system: ^System, using game: ^Game) {
// 		},
// 		update = renderer_update,
// 		needObject = proc(system: ^System, game: ^Game, obj_index: int) -> bool {
// 			obj := game.objects[obj_index]
// 			return has_desired_components(&obj, system.components_needed)
// 		},
// 		addObject = addObject,
// 		removeObject = proc(system: ^System, game: ^Game, obj_index: int) {

// 		},
// 	}
// }

// add_sprite :: proc(game: ^Game, sprite_filename: string) -> ^rl.Texture2D {
// 	if sprite_filename in game.textures {
// 		return &game.textures[sprite_filename]
// 	}
// 	game.textures[sprite_filename] = rl.LoadTexture(strings.clone_to_cstring(sprite_filename))
// 	return &game.textures[sprite_filename]
// }
