package gui

Layout_State :: enum {
	HORIZONTAL,
	VERTICAL,
}

Layout :: struct {
	rect:  Rect,
	state: Layout_State,
}

layout_new :: proc(rect: Rect) -> Layout {
	return {rect, .VERTICAL}
}

layout_get_rect :: proc(layout: ^Layout, width, height: i32) -> (result: Rect) {
	if layout.state == .HORIZONTAL {
		w := width
		if w == -1 {
			w = layout.rect.w
		}

		// Height doesn't matter. To keep things simple, we will make the height the full height of the remaining rect
		result = Rect{layout.rect.x, layout.rect.y, w, layout.rect.h}
		layout.rect.x += width
		layout.rect.w -= width
	} else if layout.state == .VERTICAL {
		h := height
		if h == -1 {
			h = layout.rect.h
		}

		// Width doesn't matter. To keep things simple, we will make the height the full width of the rect rect
		result = Rect{layout.rect.x, layout.rect.y, layout.rect.w, h}
		layout.rect.y += height
		layout.rect.h -= height
	}

	return
}

// When state is vertical, the "end" is the bottom of the rect, when state is horizontal, the "end" is the right of the rect
layout_get_rect_at_end :: proc(layout: ^Layout, width, height: i32) -> (result: Rect) {
	if layout.state == .HORIZONTAL {
		result = Rect{layout.rect.x + layout.rect.w - width, layout.rect.y, width, layout.rect.h}
		layout.rect.w -= width
	} else if layout.state == .VERTICAL {
		result = Rect{layout.rect.x, layout.rect.y + layout.rect.h - height, layout.rect.w, height}
		layout.rect.h -= height
	}

	return
}
