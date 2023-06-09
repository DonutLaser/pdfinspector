package main

import "core:fmt"
import "core:os"
import "gui"
import "app"

Args :: struct {
	filename: string,
}

parse_args :: proc() -> (Args, bool) {
	args := os.args[1:]

	if len(args) == 0 {
		fmt.eprintf("Error: filename is not provided\n")
		return Args{}, false
	}

	result := Args {
		filename = args[0],
	}

	return result, true
}

print_usage :: proc() {
	fmt.println("Usage: pdfdebugger <path/to/file.pdf>")
}

main :: proc() {
	args, args_ok := parse_args()
	if !args_ok {
		print_usage()
		return
	}

	window, ok := gui.init_window("Pdf Inspector", 1280, 720)
	if !ok {return}
	defer gui.close_window(window)

	gui.set_background_color(&window, 0, 0, 0, 255)

	application, app_ok := app.app_new(&window, args.filename)
	if !app_ok {return}
	defer app.app_destroy(&application)

	for {
		quit := gui.handle_events(&window)
		if quit {break}

		if window.resized {
			app.app_resize(&application)
		}

		gui.begin_frame(&window)

		app.app_tick(&application, &window.input)
		app.app_render(&application)

		gui.end_frame(&window)
	}
}
