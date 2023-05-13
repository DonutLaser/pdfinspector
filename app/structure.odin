package app

import "../gui"

Structure :: struct {}

create_structure :: proc() -> Structure {
	return Structure{}
}

tick_structure :: proc(s: ^Structure, app: ^App, input: ^gui.Input) {

}

render_structure :: proc(s: ^Structure, app: ^App) {
	gui.draw_rect(
		app.window,
		TABS_WIDTH,
		0,
		STRUCTURE_WIDTH,
		app.window.height,
		STRUCTURE_BG_COLOR,
	)
}
