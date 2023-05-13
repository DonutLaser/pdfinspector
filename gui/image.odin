package gui

import "core:fmt"
import sdl "vendor:sdl2"
import img "vendor:sdl2/image"
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
	surface := sdl.CreateRGBSurfaceFrom(
		bitmap.data,
		bitmap.width,
		bitmap.height,
		32,
		bitmap.stride,
		0x0000ff00,
		0x00ff0000,
		0xff000000,
		0x000000ff,
	)
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
