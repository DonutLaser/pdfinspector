package gui

import "core:fmt"
import sdl "vendor:sdl2"

Button_State :: enum {
	RELEASED,
	JUST_PRESSED,
	PRESSED,
	JUST_RELEASED,
}

Input :: struct {
	mouse_x:  i32,
	mouse_y:  i32,
	scroll_y: i32,
	lmb:      Button_State,
	rmb:      Button_State,
	char:     byte,
	ctrl:     Button_State,
	alt:      Button_State,
	shift:    Button_State,
	escape:   Button_State,
}

@(private = "file")
get_char :: proc(lowercase: byte, uppercase: byte, shift: bool) -> byte {
	return shift ? uppercase : lowercase
}

@(private)
key_to_char :: proc(key: sdl.Keycode, mod: sdl.Keymod) -> byte {
	shift := card((mod & sdl.KMOD_SHIFT) | (mod & sdl.KMOD_CAPS)) != 0

	#partial switch key {
	case sdl.Keycode.q:
		return get_char('q', 'Q', shift)
	case sdl.Keycode.w:
		return get_char('w', 'W', shift)
	case sdl.Keycode.e:
		return get_char('e', 'E', shift)
	case sdl.Keycode.r:
		return get_char('r', 'R', shift)
	case sdl.Keycode.t:
		return get_char('t', 'T', shift)
	case sdl.Keycode.y:
		return get_char('y', 'Y', shift)
	case sdl.Keycode.u:
		return get_char('u', 'U', shift)
	case sdl.Keycode.i:
		return get_char('i', 'I', shift)
	case sdl.Keycode.o:
		return get_char('o', 'O', shift)
	case sdl.Keycode.p:
		return get_char('p', 'P', shift)
	case sdl.Keycode.LEFTBRACKET:
		return get_char('[', '{', shift)
	case sdl.Keycode.RIGHTBRACKET:
		return get_char(']', '}', shift)
	case sdl.Keycode.BACKSLASH:
		return get_char('\\', '|', shift)
	case sdl.Keycode.a:
		return get_char('a', 'A', shift)
	case sdl.Keycode.s:
		return get_char('s', 'S', shift)
	case sdl.Keycode.d:
		return get_char('d', 'D', shift)
	case sdl.Keycode.f:
		return get_char('f', 'F', shift)
	case sdl.Keycode.g:
		return get_char('g', 'G', shift)
	case sdl.Keycode.h:
		return get_char('h', 'H', shift)
	case sdl.Keycode.j:
		return get_char('j', 'J', shift)
	case sdl.Keycode.k:
		return get_char('k', 'K', shift)
	case sdl.Keycode.l:
		return get_char('l', 'L', shift)
	case sdl.Keycode.SEMICOLON:
		return get_char(';', ':', shift)
	case sdl.Keycode.QUOTE:
		return get_char('\'', '"', shift)
	case sdl.Keycode.z:
		return get_char('z', 'Z', shift)
	case sdl.Keycode.x:
		return get_char('x', 'X', shift)
	case sdl.Keycode.c:
		return get_char('c', 'C', shift)
	case sdl.Keycode.v:
		return get_char('v', 'V', shift)
	case sdl.Keycode.b:
		return get_char('b', 'B', shift)
	case sdl.Keycode.n:
		return get_char('n', 'N', shift)
	case sdl.Keycode.m:
		return get_char('m', 'M', shift)
	case sdl.Keycode.COMMA:
		return get_char(',', '<', shift)
	case sdl.Keycode.PERIOD:
		return get_char('.', '>', shift)
	case sdl.Keycode.SLASH:
		return get_char('/', '?', shift)
	case sdl.Keycode.SPACE:
		return get_char(' ', ' ', shift)
	case sdl.Keycode.BACKQUOTE:
		return get_char('`', '~', shift)
	case sdl.Keycode.NUM1:
		return get_char('1', '!', shift)
	case sdl.Keycode.NUM2:
		return get_char('2', '@', shift)
	case sdl.Keycode.NUM3:
		return get_char('3', '#', shift)
	case sdl.Keycode.NUM4:
		return get_char('4', '$', shift)
	case sdl.Keycode.NUM5:
		return get_char('5', '%', shift)
	case sdl.Keycode.NUM6:
		return get_char('6', '^', shift)
	case sdl.Keycode.NUM7:
		return get_char('7', '&', shift)
	case sdl.Keycode.NUM8:
		return get_char('8', '*', shift)
	case sdl.Keycode.NUM9:
		return get_char('9', '(', shift)
	case sdl.Keycode.NUM0:
		return get_char('0', ')', shift)
	case sdl.Keycode.MINUS:
		return get_char('-', '_', shift)
	case sdl.Keycode.EQUALS:
		return get_char('=', '+', shift)
	case sdl.Keycode.RETURN:
		return get_char('\n', '\n', shift)
	case sdl.Keycode.TAB:
		return get_char('\t', '\t', shift)
	case:
		return 0
	}
}

@(private)
update_input :: proc(input: ^Input) {
	input.lmb = update_input_button(input.lmb)
	input.rmb = update_input_button(input.rmb)

	input.ctrl = update_input_button(input.ctrl)
	input.alt = update_input_button(input.alt)
	input.shift = update_input_button(input.shift)

	input.scroll_y = 0
}

update_input_button :: proc(btn: Button_State) -> Button_State {
	if btn == .JUST_RELEASED {return .RELEASED}
	if btn == .JUST_PRESSED {return .PRESSED}
	return btn
}
