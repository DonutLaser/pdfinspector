package gui

import "core:fmt"
import "core:strings"
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

measure_text_u16 :: proc(font: ^Font, text: Text_u16) -> (i32, i32) {
	return text.size * font.char_width, font.size
}

truncate_text :: proc(font: ^Font, text: cstring, max_width: i32) -> (cstring, bool) {
	width, _ := measure_text(font, text)

	if width <= max_width {
		return text, false
	}

	// -3, because we want the string to have ellipsis at the end, so we need to get rid of 3 extra characters
	retain_count := max_width / font.char_width - 3
	str := string(text)
	str = str[:retain_count]

	result_str := fmt.aprintf("%s...", str)
	defer delete(result_str)

	return strings.clone_to_cstring(result_str), true
}
