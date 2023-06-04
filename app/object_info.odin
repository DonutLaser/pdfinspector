package app

import "../gui"

@(private = "file")
instance := Object_Info{}
@(private = "file")
initialized := false

Object_Info_Field :: struct {
	name:  cstring,
	value: cstring,
}

Object_Info :: struct {
	rect:          gui.Rect,
	viewport_rect: gui.Rect,
	fields:        ^[dynamic]Tuple,
	is_visible:    bool,
}

object_info_init :: proc(rect: gui.Rect) {
	if initialized {
		return
	}

	instance.rect = rect
	instance.viewport_rect = gui.contract_rect(instance.rect, OBJECT_INFO_PADDING)

	initialized = true
}

object_info_show :: proc(fields: ^[dynamic]Tuple) {
	instance.fields = fields
	instance.is_visible = true
}

object_info_hide :: proc() {
	instance.is_visible = false
}

object_info_resize :: proc(rect: gui.Rect) {
	instance.rect = rect
	instance.viewport_rect = gui.contract_rect(instance.rect, OBJECT_INFO_PADDING)
}

object_info_tick :: proc(input: ^gui.Input) {

}

object_info_render :: proc(app: ^App) {
	gui.draw_rect(app.window, instance.rect, OBJECT_INFO_BG_COLOR)

	if !instance.is_visible {
		return
	}

	gui.clip_rect(app.window, instance.rect)

	font := assets_get_font_at_size(14)

	layout := gui.layout_new(instance.viewport_rect)
	for field in instance.fields {
		rect := gui.layout_get_rect(&layout, -1, font.size) // Width doesn't matter
		row_layout := gui.layout_new(rect)
		row_layout.state = .HORIZONTAL

		name_width, _ := gui.measure_text(font, field.key)
		name_rect := gui.layout_get_rect(&row_layout, name_width, -1) // Height doesn't matter
		gui.draw_text(
			app.window,
			font,
			gui.Text{field.key, false},
			gui.Rect{name_rect.x, name_rect.y, -1, -1},
			OBJECT_INFO_TEXT_COLOR,
		)

		value_width, _ := gui.measure_text(font, field.value)
		value_rect := gui.layout_get_rect_at_end(&row_layout, value_width, -1) // Height doesn't matter
		gui.draw_text(
			app.window,
			font,
			gui.Text{field.value, false},
			gui.Rect{value_rect.x, value_rect.y, -1, -1},
			OBJECT_INFO_TEXT_COLOR,
		)

		_ = gui.layout_get_rect(&layout, -1, OBJECT_INFO_LINE_SPACING)
	}

	gui.unclip_rect(app.window)
}
