package gui

import "core:slice"
import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

Draw_Instruction_Type :: enum {
	RECT,
	TEXT,
	TEXT_U16,
	IMAGE,
	CLIP,
}

Draw_Instruction_Rect :: struct {
	rect:          Rect,
	color:         Color,
	border_weight: i32,
}

Draw_Instruction_Text :: struct {
	font:  ^Font,
	text:  union {
		Text,
		Text_u16,
	},
	rect:  Rect,
	color: Color,
}

Draw_Instruction_Text_Rect :: struct {
	font:  ^Font,
	text:  union {
		Text,
		Text_u16,
	},
	rect:  Rect,
	color: Color,
}

Draw_Instruction_Image :: struct {
	img:   ^Image,
	x, y:  i32,
	color: Color,
}

Draw_Instruction_Clip :: struct {
	clip: bool,
	rect: Rect,
}

Draw_Instruction :: struct {
	it:      Draw_Instruction_Type,
	data:    union {
		Draw_Instruction_Rect,
		Draw_Instruction_Text,
		Draw_Instruction_Text_Rect,
		Draw_Instruction_Image,
		Draw_Instruction_Clip,
	},
	z_index: i32,
}

draw_rect :: proc(window: ^Window, rect: Rect, color: Color, border_weight: i32 = 0, z_index: i32 = 0) {
	append(
		&window.render_queue,
		Draw_Instruction{it = .RECT, data = Draw_Instruction_Rect{rect, color, border_weight}, z_index = z_index},
	)
}

draw_text :: proc(window: ^Window, font: ^Font, text: Text, rect: Rect, color: Color, z_index: i32 = 0) {
	append(
		&window.render_queue,
		Draw_Instruction{it = .TEXT, data = Draw_Instruction_Text{font, text, rect, color}, z_index = z_index},
	)
}

draw_text_u16 :: proc(window: ^Window, font: ^Font, text: Text_u16, rect: Rect, color: Color, z_index: i32 = 0) {
	append(
		&window.render_queue,
		Draw_Instruction{it = .TEXT_U16, data = Draw_Instruction_Text{font, text, rect, color}, z_index = z_index},
	)

}

draw_image :: proc(window: ^Window, img: ^Image, x, y: i32, color: Color, z_index: i32 = 0) {
	append(
		&window.render_queue,
		Draw_Instruction{it = .IMAGE, data = Draw_Instruction_Image{img, x, y, color}, z_index = z_index},
	)
}

clip_rect :: proc(window: ^Window, rect: Rect) {
	append(&window.render_queue, Draw_Instruction{it = .CLIP, data = Draw_Instruction_Clip{true, rect}, z_index = 0})
}

unclip_rect :: proc(window: ^Window) {
	append(
		&window.render_queue,
		Draw_Instruction{it = .CLIP, data = Draw_Instruction_Clip{false, Rect{0, 0, 0, 0}}, z_index = 0},
	)
}


@(private)
draw_render_queue :: proc(renderer: ^sdl.Renderer, queue: ^[dynamic]Draw_Instruction) {
	slice.stable_sort_by_cmp(queue[:], proc(i1: Draw_Instruction, i2: Draw_Instruction) -> slice.Ordering {
		if i1.z_index < i2.z_index {return .Less}
		if i1.z_index > i2.z_index {return .Greater}
		return .Equal
	})

	for instruction in queue {
		switch instruction.it {
		case .RECT:
			render_rect(renderer, instruction.data.(Draw_Instruction_Rect))
		case .TEXT:
			render_text(renderer, instruction.data.(Draw_Instruction_Text))
		case .TEXT_U16:
			render_text_u16(renderer, instruction.data.(Draw_Instruction_Text))
		case .IMAGE:
			render_image(renderer, instruction.data.(Draw_Instruction_Image))
		case .CLIP:
			clip_rect(renderer, instruction.data.(Draw_Instruction_Clip))
		}
	}

	clear_dynamic_array(queue)
}

@(private = "file")
render_rect :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Rect) {
	sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.BLEND)

	sdl.SetRenderDrawColor(renderer, i.color.r, i.color.g, i.color.b, i.color.a)

	if i.border_weight > 0 {
		top := sdl.Rect{i.rect.x, i.rect.y, i.rect.w, i.border_weight}
		right := sdl.Rect{i.rect.x + i.rect.w - i.border_weight, i.rect.y, i.border_weight, i.rect.h}
		bottom := sdl.Rect{i.rect.x, i.rect.y + i.rect.h - i.border_weight, i.rect.w, i.border_weight}
		left := sdl.Rect{i.rect.x, i.rect.y, i.border_weight, i.rect.h}

		sdl.RenderFillRect(renderer, &top)
		sdl.RenderFillRect(renderer, &right)
		sdl.RenderFillRect(renderer, &bottom)
		sdl.RenderFillRect(renderer, &left)
	} else {
		sdl.RenderFillRect(renderer, &sdl.Rect{i.rect.x, i.rect.y, i.rect.w, i.rect.h})
	}

	sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.NONE)
}

@(private = "file")
render_text :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Text) {
	txt := i.text.(Text)
	surface := ttf.RenderUTF8_Blended(i.font.instance, txt.data, sdl.Color{i.color.r, i.color.g, i.color.b, i.color.a})
	defer sdl.FreeSurface(surface)

	texture := sdl.CreateTextureFromSurface(renderer, surface)
	defer sdl.DestroyTexture(texture)

	rect := sdl.Rect{i.rect.x, i.rect.y, i.rect.w, i.rect.h}
	if i.rect.w == -1 || i.rect.h == -1 {
		text_width, text_height := measure_text(i.font, txt.data)
		rect = sdl.Rect{i.rect.x, i.rect.y, text_width, text_height}
	}

	sdl.RenderCopy(renderer, texture, nil, &rect)

	if (txt.allocated) {
		delete(txt.data)
	}
}

@(private = "file")
render_text_u16 :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Text) {
	txt := i.text.(Text_u16)
	surface := ttf.RenderUNICODE_Blended_Wrapped(
		i.font.instance,
		txt.data,
		sdl.Color{i.color.r, i.color.g, i.color.b, i.color.a},
		u32(i.rect.w),
	)
	defer sdl.FreeSurface(surface)

	texture := sdl.CreateTextureFromSurface(renderer, surface)
	defer sdl.DestroyTexture(texture)

	rect := sdl.Rect{i.rect.x, i.rect.y, i.rect.w, i.rect.h}
	if i.rect.w == -1 || i.rect.h == -1 {
		// text_width, text_height := measure_text(i.font, txt.data)
		// rect = sdl.Rect{i.rect.x, i.rect.y, text_width, text_height}
	}

	sdl.RenderCopy(renderer, texture, &sdl.Rect{0, 0, i.rect.w, i.rect.h}, &rect)
}

@(private = "file")
render_image :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Image) {
	rect := sdl.Rect{i.x, i.y, i.img.width, i.img.height}

	sdl.SetTextureColorMod(i.img.instance, i.color.r, i.color.g, i.color.b)
	sdl.RenderCopy(renderer, i.img.instance, nil, &rect)
}

@(private = "file")
clip_rect :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Clip) {
	if i.clip {
		sdl.RenderSetClipRect(renderer, &sdl.Rect{i.rect.x, i.rect.y, i.rect.w, i.rect.h})
	} else {
		sdl.RenderSetClipRect(renderer, nil)
	}
}
