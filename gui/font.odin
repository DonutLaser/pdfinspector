package gui

import "core:fmt"
import ttf "vendor:sdl2/ttf"

Font :: struct {
	instance:   ^ttf.Font,
	size:       i32,
	char_width: i32,
}

load_font :: proc(path: cstring, size: i32) -> (Font, bool) {
	data := ttf.OpenFont(path, size)
	if data == nil {
		print_ttf_error()
		return Font{}, false
	}

	minx, maxx, miny, maxy, advance: i32
	ok := ttf.GlyphMetrics(data, 'm', &minx, &maxx, &miny, &maxy, &advance)
	if ok != 0 {
		print_ttf_error()
		return Font{}, false
	}

	return Font{instance = data, size = size, char_width = advance}, true
}

close_font :: proc(font: ^Font) {
	ttf.CloseFont(font.instance)
}

measure_text :: proc(font: ^Font, text: cstring) -> (i32, i32) {
	return i32(len(text)) * font.char_width, font.size
}
