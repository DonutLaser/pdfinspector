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

Text_u16 :: struct {
	data: [^]u16,
	size: i32,
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
