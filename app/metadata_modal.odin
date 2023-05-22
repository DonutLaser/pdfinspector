package app

import "core:strings"
import "core:fmt"
import "../gui"

Metadata_Field :: struct {
	name:  cstring,
	value: cstring,
}

Metadata_Modal :: struct {
	is_visible: bool,
	fields:     [dynamic]Metadata_Field,
}

create_metadata_modal :: proc() -> Metadata_Modal {
	width: i32 = METADATA_MODAL_WIDTH + METADATA_PADDING * 2
	result := Metadata_Modal {
		is_visible = false,
		fields     = make([dynamic]Metadata_Field),
	}

	return result
}

add_metadata_field :: proc(mm: ^Metadata_Modal, name: cstring, value: string, app: ^App) {
	cvalue := strings.clone_to_cstring(value)
	truncated_value, truncated := gui.truncate_text(&app.fonts[14], cvalue, 200)

	if truncated {
		delete(cvalue)
	}

	append(&mm.fields, Metadata_Field{name, truncated_value})
}

tick_metadata_modal :: proc(mm: ^Metadata_Modal, input: ^gui.Input) {
	if !mm.is_visible {
		return
	}

	if input.escape == .JUST_PRESSED || input.rmb == .JUST_PRESSED {
		mm.is_visible = false
	}
}

render_metadata_modal :: proc(mm: ^Metadata_Modal, app: ^App) {
	if !mm.is_visible {
		return
	}

	font := &app.fonts[14]

	// TODO: this is a mess
	line_count := i32(len(mm.fields))
	width: i32 = METADATA_MODAL_WIDTH + METADATA_PADDING * 2
	height: i32 =
		line_count * font.size + METADATA_PADDING * 2 + (line_count - 1) * METADATA_LINE_SPACING

	x, y := gui.get_rect_center(gui.Rect{0, 0, app.window.width, app.window.height})
	left, top := x - width / 2, y - height / 2

	modal_rect := gui.Rect{left, top, width, height}
	gui.draw_rect(app.window, modal_rect, MODAL_BG_COLOR)
	gui.draw_rect(app.window, modal_rect, MODAL_BORDER_COLOR, 1)

	cursor_x, cursor_y := left + METADATA_PADDING, top + METADATA_PADDING
	for field, index in mm.fields {
		gui.draw_text(
			app.window,
			font,
			gui.Text{data = field.name, allocated = false},
			gui.Rect{cursor_x, cursor_y, -1, -1},
			METADATA_MODAL_TEXT_COLOR,
		)

		value_width, _ := gui.measure_text(font, field.value)

		gui.draw_text(
			app.window,
			font,
			gui.Text{data = field.value, allocated = false},
			gui.Rect{left + width - METADATA_PADDING - value_width, cursor_y, -1, -1},
			METADATA_MODAL_TEXT_COLOR,
		)

		if index != len(mm.fields) - 1 {
			cursor_y += METADATA_LINE_SPACING + font.size
		}
	}
}
