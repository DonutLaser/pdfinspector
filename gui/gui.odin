package gui

import "core:fmt"
import "core:os"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

Window :: struct {
	instance:     ^sdl.Window,
	renderer:     ^sdl.Renderer,
	render_queue: [dynamic]Draw_Instruction,
	input:        Input,
	bg_color:     sdl.Color,
	width:        i32,
	height:       i32,
	resized:      bool,
}

init_window :: proc(title: cstring, width: i32, height: i32) -> (Window, bool) {
	init_ok := sdl.Init(sdl.INIT_EVERYTHING)
	if init_ok != 0 {
		print_sdl_error()
		return Window{}, false
	}

	init_ok = ttf.Init()
	if init_ok != 0 {
		print_ttf_error()
		return Window{}, false
	}

	sdl.GL_SetAttribute(sdl.GLattr.FRAMEBUFFER_SRGB_CAPABLE, 1)

	result := Window{}
	result.instance = sdl.CreateWindow(
		title,
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		width,
		height,
		{.RESIZABLE, .MAXIMIZED},
	)
	if result.instance == nil {
		print_sdl_error()
		return Window{}, false
	}

	result.renderer = sdl.CreateRenderer(result.instance, -1, {.ACCELERATED, .PRESENTVSYNC})
	if result.renderer == nil {
		print_sdl_error()
		return Window{}, false
	}

	result.input = Input{}
	result.bg_color = sdl.Color{0, 0, 0, 255}
	result.width = width
	result.height = height

	return result, true
}

close_window :: proc(wnd: Window) {
	sdl.DestroyRenderer(wnd.renderer)
	sdl.DestroyWindow(wnd.instance)

	ttf.Quit()
	sdl.Quit()

	delete(wnd.render_queue)
}

handle_events :: proc(wnd: ^Window) -> bool {
	update_input(&wnd.input)

	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			return true
		case .WINDOWEVENT:
			#partial switch event.window.event {
			case .RESIZED:
				wnd.width = event.window.data1
				wnd.height = event.window.data2
				wnd.resized = true
			}
		case .MOUSEMOTION:
			wnd.input.mouse_x = event.motion.x
			wnd.input.mouse_y = event.motion.y
		case .MOUSEWHEEL:
			wnd.input.scroll_y = event.wheel.y
		case .MOUSEBUTTONDOWN, .MOUSEBUTTONUP:
			new_state := event.type == .MOUSEBUTTONDOWN ? Button_State.JUST_PRESSED : Button_State.JUST_RELEASED

			switch event.button.button {
			case sdl.BUTTON_LEFT:
				wnd.input.lmb = new_state
			case sdl.BUTTON_RIGHT:
				wnd.input.rmb = new_state
			}
		case .KEYDOWN, .KEYUP:
			new_state := event.type == .KEYDOWN ? Button_State.JUST_PRESSED : Button_State.JUST_RELEASED

			#partial switch event.key.keysym.sym {
			case .LCTRL, .RCTRL:
				wnd.input.ctrl = new_state
			case .LSHIFT, .RSHIFT:
				wnd.input.shift = new_state
			case .LALT, .RALT:
				wnd.input.alt = new_state
			case .ESCAPE:
				wnd.input.escape = new_state
			case:
				if new_state == .JUST_PRESSED {
					wnd.input.char = key_to_char(event.key.keysym.sym, event.key.keysym.mod)
				}
			}
		}
	}

	return false
}

set_background_color :: proc(window: ^Window, r: u8, g: u8, b: u8, a: u8) {
	window.bg_color.r = r
	window.bg_color.g = g
	window.bg_color.b = b
	window.bg_color.a = a
}

begin_frame :: proc(window: ^Window) {
	sdl.SetRenderDrawColor(window.renderer, window.bg_color.r, window.bg_color.g, window.bg_color.b, window.bg_color.a)
	sdl.RenderClear(window.renderer)
}

end_frame :: proc(window: ^Window) {
	window.resized = false

	draw_render_queue(window.renderer, &window.render_queue)
	sdl.RenderPresent(window.renderer)
}
