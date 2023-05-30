package gui

Rect :: struct {
	x, y, w, h: i32,
}

get_rect_center :: proc(r: Rect) -> (i32, i32) {
	return r.x + r.w / 2, r.y + r.h / 2
}

get_rect_end :: proc(r: Rect) -> (i32, i32) {
	return r.x + r.w, r.y + r.h
}

is_point_in_rect :: proc(x, y: i32, r: Rect) -> bool {
	return x >= r.x && x <= r.x + r.w && y >= r.y && y <= r.y + r.h
}

place_rect_in_center :: proc(parent_rect: Rect, width, height: i32) -> Rect {
	return(
		{
			parent_rect.x + parent_rect.w / 2 - width / 2,
			parent_rect.y + parent_rect.h / 2 - height / 2,
			width,
			height,
		} \
	)
}

contract_rect :: proc(rect: Rect, amount: i32) -> Rect {
	return {rect.x + amount, rect.y + amount, rect.w - amount * 2, rect.h - amount * 2}
}
