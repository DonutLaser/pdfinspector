package gui

import "core:slice"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

Draw_Instruction_Type :: enum {
	RECT,
	TEXT,
	IMAGE,
}

Draw_Instruction_Rect :: struct {
	x, y, width, height: i32,
	color:               Color,
	border_weight:       i32,
}

Draw_Instruction_Text :: struct {
	font:  ^Font,
	text:  Text,
	x, y:  i32,
	color: Color,
}

Draw_Instruction_Image :: struct {
	img:   ^Image,
	x, y:  i32,
	color: Color,
}

Draw_Instruction :: struct {
	it:      Draw_Instruction_Type,
	data:    union {
		Draw_Instruction_Rect,
		Draw_Instruction_Text,
		Draw_Instruction_Image,
	},
	z_index: i32,
}

draw_rect :: proc(
	window: ^Window,
	x: i32,
	y: i32,
	width: i32,
	height: i32,
	color: Color,
	border_weight: i32 = 0,
	z_index: i32 = 0,
) {
	append(
		&window.render_queue,
		Draw_Instruction{
			it = .RECT,
			data = Draw_Instruction_Rect{x, y, width, height, color, border_weight},
			z_index = z_index,
		},
	)
}

draw_text :: proc(
	window: ^Window,
	font: ^Font,
	text: Text,
	x: i32,
	y: i32,
	color: Color,
	z_index: i32 = 0,
) {
	append(
		&window.render_queue,
		Draw_Instruction{
			it = .TEXT,
			data = Draw_Instruction_Text{font, text, x, y, color},
			z_index = z_index,
		},
	)
}

draw_image :: proc(window: ^Window, img: ^Image, x: i32, y: i32, color: Color, z_index: i32 = 0) {
	append(
		&window.render_queue,
		Draw_Instruction{
			it = .IMAGE,
			data = Draw_Instruction_Image{img, x, y, color},
			z_index = z_index,
		},
	)
}

@(private)
draw_render_queue :: proc(renderer: ^sdl.Renderer, queue: ^[dynamic]Draw_Instruction) {
	slice.sort_by_cmp(
		queue[:],
		proc(i1: Draw_Instruction, i2: Draw_Instruction) -> slice.Ordering {
			if i1.z_index < i2.z_index {return .Less}
			if i1.z_index > i2.z_index {return .Greater}
			return .Equal
		},
	)

	for instruction in queue {
		switch instruction.it {
		case .RECT:
			render_rect(renderer, instruction.data.(Draw_Instruction_Rect))
		case .TEXT:
			render_text(renderer, instruction.data.(Draw_Instruction_Text))
		case .IMAGE:
			render_image(renderer, instruction.data.(Draw_Instruction_Image))
		}
	}

	clear_dynamic_array(queue)
}

@(private = "file")
render_rect :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Rect) {
	sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.BLEND)

	sdl.SetRenderDrawColor(renderer, i.color.r, i.color.g, i.color.b, i.color.a)

	if i.border_weight > 0 {
		top := sdl.Rect{i.x, i.y, i.width, i.border_weight}
		right := sdl.Rect{i.x + i.width - i.border_weight, i.y, i.border_weight, i.height}
		bottom := sdl.Rect{i.x, i.y + i.height - i.border_weight, i.width, i.border_weight}
		left := sdl.Rect{i.x, i.y, i.border_weight, i.height}

		sdl.RenderFillRect(renderer, &top)
		sdl.RenderFillRect(renderer, &right)
		sdl.RenderFillRect(renderer, &bottom)
		sdl.RenderFillRect(renderer, &left)
	} else {
		sdl.RenderFillRect(renderer, &sdl.Rect{i.x, i.y, i.width, i.height})
	}

	sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.NONE)
}

@(private = "file")
render_text :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Text) {
	surface := ttf.RenderUTF8_Blended(
		i.font.instance,
		i.text.data,
		sdl.Color{i.color.r, i.color.g, i.color.b, i.color.a},
	)
	defer sdl.FreeSurface(surface)

	texture := sdl.CreateTextureFromSurface(renderer, surface)
	defer sdl.DestroyTexture(texture)

	text_width, text_height := measure_text(i.font, i.text.data)
	rect := sdl.Rect{i.x, i.y, text_width, text_height}

	sdl.RenderCopy(renderer, texture, nil, &rect)

	if (i.text.allocated) {
		delete(i.text.data)
	}
}

@(private = "file")
render_image :: proc(renderer: ^sdl.Renderer, i: Draw_Instruction_Image) {
	rect := sdl.Rect{i.x, i.y, i.img.width, i.img.height}

	sdl.SetTextureColorMod(i.img.instance, i.color.r, i.color.g, i.color.b)
	sdl.RenderCopy(renderer, i.img.instance, nil, &rect)
}

// clip_rect :: proc(window: ^Window, x: i32, y: i32, width: i32, height: i32) {
// 	sdl.RenderSetClipRect(window.renderer, &sdl.Rect{x, y, width, height})
// }

// unclip_rect :: proc(window: ^Window) {
// 	sdl.RenderSetClipRect(window.renderer, nil)
// }
