package app

import "core:strings"
import "core:fmt"
import "../gui"

@(private = "file")
instance := Metadata_Modal{}

Metadata_Field :: struct {
	name:  cstring,
	value: cstring,
}

Metadata_Modal :: struct {
	rect:          gui.Rect,
	viewport_rect: gui.Rect,
	fields:        [dynamic]Metadata_Field,
}

metadata_modal_add_field :: proc(name: cstring, value: cstring) {
	append(&instance.fields, Metadata_Field{name, value})
}

metadata_modal_show :: proc(parent_rect: gui.Rect) {
	font_size: i32 = 14 // We know that's the size of the font we will use
	field_count: i32 = i32(len(instance.fields))

	width: i32 = METADATA_MODAL_WIDTH
	height: i32 =
		field_count * font_size + (field_count - 1) * METADATA_MODAL_LINE_SPACING + METADATA_MODAL_PADDING * 2
	instance.rect = gui.place_rect_in_center(parent_rect, width, height)
	instance.viewport_rect = gui.contract_rect(instance.rect, METADATA_MODAL_PADDING)
}

// TODO: resize this

metadata_modal_tick :: proc(input: ^gui.Input) {
}

metadata_modal_render :: proc(app: ^App) {
	font := assets_get_font_at_size(14)

	gui.draw_rect(app.window, instance.rect, MODAL_BG_COLOR)
	gui.draw_rect(app.window, instance.rect, MODAL_BORDER_COLOR, 1)

	layout := gui.layout_new(instance.viewport_rect)
	for field in instance.fields {
		rect := gui.layout_get_rect(&layout, -1, font.size) // Width doesn't matter
		row_layout := gui.layout_new(rect)
		row_layout.state = .HORIZONTAL

		name_width, _ := gui.measure_text(font, field.name)
		name_rect := gui.layout_get_rect(&row_layout, name_width, -1) // Height doesn't matter
		gui.draw_text(
			app.window,
			font,
			gui.Text{data = field.name, allocated = false},
			gui.Rect{name_rect.x, name_rect.y, -1, -1},
			METADATA_MODAL_TEXT_COLOR,
		)

		value_width, _ := gui.measure_text(font, field.value)
		value_rect := gui.layout_get_rect_at_end(&row_layout, value_width, -1) // Height doesn't matter
		gui.draw_text(
			app.window,
			font,
			gui.Text{data = field.value, allocated = false},
			gui.Rect{value_rect.x, value_rect.y, -1, -1},
			METADATA_MODAL_TEXT_COLOR,
		)

		_ = gui.layout_get_rect(&layout, -1, METADATA_MODAL_LINE_SPACING)
	}
}
