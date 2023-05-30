package app

import "../gui"

@(private = "file")
fonts: map[i32]gui.Font
@(private = "file")
icons: map[string]gui.Image

@(private = "file")
Image_To_Load :: struct {
	path: cstring,
	name: string,
}

@(private = "file")
Font_To_Load :: struct {
	path: cstring,
	size: i32,
}

assets_init :: proc(window: ^gui.Window) {
	// Load fonts
	fonts_to_load := []Font_To_Load{{"./assets/fonts/consola.ttf", 14}}
	for f in fonts_to_load {
		font, ok := gui.load_font(f.path, f.size)
		if !ok {panic("Cannot load a font")}

		fonts[f.size] = font
	}

	// Load icons
	images_to_load := []Image_To_Load{
		Image_To_Load{"./assets/icons/text.png", "text.png"},
		Image_To_Load{"./assets/icons/metadata.png", "metadata.png"},
	}
	for image in images_to_load {
		icon, ok := gui.load_image(image.path, window)
		if !ok {panic("Cannot load icon")}

		icons[image.name] = icon
	}
}

assets_get_font_at_size :: proc(size: i32) -> ^gui.Font {
	assert(size in fonts)
	return &fonts[size]
}

assets_get_image :: proc(name: string) -> ^gui.Image {
	assert(name in icons)
	return &icons[name]
}
