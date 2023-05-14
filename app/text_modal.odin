package app

import "../gui"

Text_Modal :: struct {
	is_visible: bool,
}

create_text_modal :: proc() -> Text_Modal {
	result := Text_Modal{}

	return result
}

tick_text_modal :: proc(tm: ^Text_Modal, input: ^gui.Input) {
	if !tm.is_visible {
		return
	}

	if input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED {
		tm.is_visible = false
	}
}

render_text_modal :: proc(tm: ^Text_Modal, app: ^App) {
	if !tm.is_visible {
		return
	}

	gui.draw_rect(app.window, 0, 0, app.window.width, app.window.height, MODAL_OVERLAY_COLOR)

	x, y := gui.get_rect_center(0, 0, app.window.width, app.window.height)
	left, top := x - TEXT_MODAL_WIDTH / 2, y - TEXT_MODAL_HEIGHT / 2
	gui.draw_rect(app.window, left, top, TEXT_MODAL_WIDTH, TEXT_MODAL_HEIGHT, MODAL_BG_COLOR)
	gui.draw_rect(
		app.window,
		left,
		top,
		TEXT_MODAL_WIDTH,
		TEXT_MODAL_HEIGHT,
		MODAL_BORDER_COLOR,
		1,
	)
}
