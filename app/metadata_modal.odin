package app

import "../gui"
import "core:strings"

Metadata_Field :: struct {
	name:  string,
	value: string,
}

Metadata_Modal :: struct {
	is_visible: bool,
	fields:     [dynamic]Metadata_Field,
}

create_metadata_modal :: proc() -> Metadata_Modal {
	result := Metadata_Modal {
		is_visible = false,
		fields     = make([dynamic]Metadata_Field),
	}

	return result
}

add_metadata_field :: proc(mm: ^Metadata_Modal, name: string, value: string) {
	// TODO: just hardcode the fields, no need to make the array dynamic
	append(&mm.fields, Metadata_Field{name, value})
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

	gui.draw_rect(app.window, 0, 0, app.window.width, app.window.height, MODAL_OVERLAY_COLOR)

	// TODO: this is a mess
	field_count := i32(len(mm.fields))
	height := font.size * field_count + METADATA_LINE_SPACING * (field_count - 1)
	x, y := gui.get_rect_center(0, 0, app.window.width, app.window.height)
	left, top := x - METADATA_MODAL_WIDTH / 2 - METADATA_PADDING, y - height / 2 - METADATA_PADDING
	gui.draw_rect(
		app.window,
		left,
		top,
		METADATA_MODAL_WIDTH + METADATA_PADDING * 2,
		height + METADATA_PADDING * 2,
		METADATA_MODAL_BG_COLOR,
	)
	gui.draw_rect(
		app.window,
		left,
		top,
		METADATA_MODAL_WIDTH + METADATA_PADDING * 2,
		height + METADATA_PADDING * 2,
		METADATA_MODAL_BORDER_COLOR,
		1,
	)

	x, y = x - METADATA_MODAL_WIDTH / 2, y - height / 2
	for field, index in mm.fields {
		cname := strings.clone_to_cstring(field.name)
		gui.draw_text(
			app.window,
			font,
			gui.Text{data = cname, allocated = true},
			x,
			y,
			METADATA_MODAL_TEXT_COLOR,
		)

		y += font.size
		if index != len(mm.fields) - 1 {
			y += METADATA_LINE_SPACING
		}
	}
}
