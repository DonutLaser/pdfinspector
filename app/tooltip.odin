package app

import "../gui"

Tooltip :: struct {
	rect:       gui.Rect,
	text:       cstring,
	is_visible: bool,
}

tooltip_new :: proc() -> Tooltip {
	return {}
}

tooltip_set_text :: proc(t: ^Tooltip, text: cstring) {
	font := assets_get_font_at_size(14)

	t.text = text
	text_width, text_height := gui.measure_text(font, t.text)

	// Position is dynamic
	t.rect = gui.Rect{0, 0, text_width + TOOLTIP_PADDING * 2, text_height + TOOLTIP_PADDING * 2}
}

tooltip_show_at :: proc(t: ^Tooltip, x, y: i32) {
	t.is_visible = true
	t.rect.x = x
	t.rect.y = y
}

tooltip_hide :: proc(t: ^Tooltip) {
	t.is_visible = false
}

tooltip_render :: proc(t: ^Tooltip, app: ^App) {
	if !t.is_visible {
		return
	}

	font := assets_get_font_at_size(14)

	gui.draw_rect(app.window, t.rect, TOOLTIP_BG_COLOR, 0, 777)
	gui.draw_text(
		app.window,
		font,
		gui.Text{t.text, false},
		gui.Rect{t.rect.x + TOOLTIP_PADDING, t.rect.y + TOOLTIP_PADDING, -1, -1},
		TOOLTIP_TEXT_COLOR,
		777,
	)
}
