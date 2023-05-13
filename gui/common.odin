package gui

import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"
import img "vendor:sdl2/image"

Color :: struct {
	r, g, b, a: u8,
}

Text :: struct {
	data:      cstring,
	allocated: bool,
}

is_point_in_rect :: proc(
	rect_x: i32,
	rect_y: i32,
	rect_width: i32,
	rect_height: i32,
	x: i32,
	y: i32,
) -> bool {
	return x >= rect_x && x <= rect_x + rect_width && y >= rect_y && y <= rect_y + rect_height
}

get_rect_center :: proc(x: i32, y: i32, width: i32, height: i32) -> (i32, i32) {
	return x + width / 2, y + height / 2
}

@(private)
print_sdl_error :: proc() {
	err := sdl.GetError()
	fmt.eprintf("Error: %s\n", err)
}

@(private)
print_ttf_error :: proc() {
	err := ttf.GetError()
	fmt.eprintf("Error: %s\n", err)
}

@(private)
print_image_error :: proc() {
	err := img.GetError()
	fmt.eprintf("Error: %s\n", err)
}
