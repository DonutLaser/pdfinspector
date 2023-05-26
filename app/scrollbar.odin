package app

import "core:fmt"
import "../gui"

Scrollbar :: struct {
	rect:              gui.Rect,
	handle_rect:       gui.Rect,
	content_height:    i32,
	max_scroll:        i32,
	max_handle_scroll: i32,
	handle_scroll:     i32,
	is_visible:        bool,
}

create_scrollbar :: proc(parent_rect: gui.Rect) -> Scrollbar {
	rect := gui.Rect{
		parent_rect.x + parent_rect.w - SCROLLBAR_SIZE,
		parent_rect.y,
		SCROLLBAR_SIZE,
		parent_rect.h,
	}

	result := Scrollbar {
		rect = rect,
		handle_rect = gui.Rect{},
		content_height = 0,
		max_scroll = 0,
		max_handle_scroll = 0,
		handle_scroll = 0,
		is_visible = false,
	}

	return result
}

resize_scrollbar :: proc(s: ^Scrollbar, parent_rect: gui.Rect) {
	s.rect.x = parent_rect.x + parent_rect.w - SCROLLBAR_SIZE
	s.rect.y = parent_rect.y
	s.rect.w = SCROLLBAR_SIZE
	s.rect.h = parent_rect.h

	s.handle_rect.x = s.rect.x
	s.handle_rect.y = s.rect.y
	s.handle_rect.w = s.rect.w
}

show_scrollbar :: proc(s: ^Scrollbar, viewport_height, content_height: i32) {
	s.is_visible = true

	s.handle_rect = gui.Rect{
		s.rect.x,
		s.rect.y,
		s.rect.w,
		i32(f32(viewport_height) / f32(content_height) * f32(s.rect.h)),
	}
	s.max_scroll = content_height - viewport_height
	s.max_handle_scroll = s.rect.h - s.handle_rect.h
}

hide_scrollbar :: proc(s: ^Scrollbar) {
	s.is_visible = false
}

update_scrollbar_offset :: proc(s: ^Scrollbar, full_offset: i32) {
	s.handle_scroll = i32(f32(-full_offset) / f32(s.max_scroll) * f32(s.max_handle_scroll))
}

render_scrollbar :: proc(s: ^Scrollbar, app: ^App) {
	if !s.is_visible {
		return
	}

	gui.draw_rect(app.window, s.rect, SCROLLBAR_BG_COLOR)
	gui.draw_rect(
		app.window,
		gui.Rect{
			s.handle_rect.x,
			s.handle_rect.y + s.handle_scroll,
			s.handle_rect.w,
			s.handle_rect.h,
		},
		SCROLLBAR_HANDLE_COLOR,
	)
}
