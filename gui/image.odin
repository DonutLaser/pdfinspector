package gui

import "core:fmt"
import sdl "vendor:sdl2"
import img "vendor:sdl2/image"
import ttf "vendor:sdl2/ttf"
import "../pdf"

Image :: struct {
	instance: ^sdl.Texture,
	width:    i32,
	height:   i32,
}

load_image :: proc(path: cstring, window: ^Window) -> (Image, bool) {
	surface := img.Load(path)
	if surface == nil {
		print_image_error()
		return Image{}, false
	}
	defer sdl.FreeSurface(surface)

	return produce_image(surface, window)
}

close_image :: proc(image: ^Image) {
	sdl.DestroyTexture(image.instance)
}

image_from_pdf_bitmap :: proc(bitmap: pdf.Bitmap, window: ^Window) -> (Image, bool) {
	// Pdf bitmap is BGRA8888, but for some reason, here we need to specify ARGB8888.
	// I have no idea why, maybe it has something to do with endianness, but only 
	// this format works and produces accurate colors.
	surface := sdl.CreateRGBSurfaceWithFormatFrom(
		bitmap.data,
		bitmap.width,
		bitmap.height,
		32,
		bitmap.stride,
		u32(sdl.PixelFormatEnum.ARGB8888),
	)
	if surface == nil {
		print_sdl_error()
		return Image{}, false
	}
	defer sdl.FreeSurface(surface)

	return produce_image(surface, window)
}

image_from_pdf_text :: proc(txt: pdf.Pdf_Text, font: ^Font, width: i32, window: ^Window) -> (Image, bool) {
	surface := ttf.RenderUNICODE_Blended_Wrapped(font.instance, txt.data, sdl.Color{255, 255, 255, 255}, u32(width))
	if surface == nil {
		print_sdl_error()
		return Image{}, false
	}
	defer sdl.FreeSurface(surface)

	return produce_image(surface, window)
}

@(private = "file")
produce_image :: proc(surface: ^sdl.Surface, window: ^Window) -> (Image, bool) {
	texture := sdl.CreateTextureFromSurface(window.renderer, surface)
	if texture == nil {
		print_sdl_error()
		return Image{}, false
	}

	return Image{instance = texture, width = surface.w, height = surface.h}, true
}
