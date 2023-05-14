package app

import "../gui"

Structure :: struct {
	rect: gui.Rect,
}

create_structure :: proc(rect: gui.Rect) -> Structure {
	return Structure{rect = rect}
}

resize_structure :: proc(s: ^Structure, h: i32) {
	s.rect.h = h
}

tick_structure :: proc(s: ^Structure, app: ^App, input: ^gui.Input) {

}

render_structure :: proc(s: ^Structure, app: ^App) {
	gui.draw_rect(app.window, s.rect, STRUCTURE_BG_COLOR)
}
