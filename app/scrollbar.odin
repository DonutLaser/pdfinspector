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

scrollbar_setup :: proc(s: ^Scrollbar, parent_rect, viewport_rect: gui.Rect, content_height: i32) {
	s.rect = gui.Rect{
		parent_rect.x + parent_rect.w - SCROLLBAR_SIZE,
		parent_rect.y,
		SCROLLBAR_SIZE,
		parent_rect.h,
	}
	s.handle_rect = gui.Rect{
		s.rect.x,
		s.rect.y,
		s.rect.w,
		i32(f32(viewport_rect.h) / f32(content_height) * f32(s.rect.h)),
	}
	s.content_height = content_height
	s.max_scroll = content_height - viewport_rect.h
	s.max_handle_scroll = s.rect.h - s.handle_rect.h

	s.is_visible = content_height > viewport_rect.h
}

scrollbar_update_offset :: proc(s: ^Scrollbar, full_offset: i32) {
	s.handle_scroll = i32(f32(-full_offset) / f32(s.max_scroll) * f32(s.max_handle_scroll))
}

scrollbar_render :: proc(s: ^Scrollbar, app: ^App) {
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
