import glib2
import gdk2
import gtk2
import cairo

const 
    lib = "libgdk-x11-2.0.dylib"



# proc cairo_destroy*(ctx: PContext) {.
#     cdecl, dynlib: lib, importc: "gdk_cairo_destroy".}

var argc = 0
var argv: array[0,int]

gtk2.init(addr(argc), addr(argv))

let win = window_new(gtk2.WINDOW_TOPLEVEL)
# win.fullscreen()

var x = 0.0
var dx = 0.0
var ddx = 0.0

when true:
    let area = drawing_area_new()

    let win_draw =
        proc (widget: PWidget) {.cdecl.} =
            echo "draw"
            var ctx = cairo_create(widget.window)
            ctx.set_source_rgb(0, 0, 0)
            ctx.set_font_size(16.0)
            ctx.move_to(x, 200)
            ctx.show_text("Hello World")
            destroy(ctx)

    discard area.signal_connect("expose-event", SIGNAL_FUNC(win_draw), nil)

    win.add(area)

when false:
    let btn = button_new("Test")

    let on_pressed =
        proc (widget: PWidget) {.cdecl.} =
            echo "Pressed"

    discard btn.signal_connect("pressed", SIGNAL_FUNC(on_pressed), nil)

    win.add(btn)

let on_key_press = 
    proc (widget: PWidget, event: PEvent): gboolean =
        echo "Yo"
        ddx = 0.1
        # win.queue_draw
        false

let anim =
    proc (): gboolean = 
        x += dx
        dx += ddx
        win.queue_draw
        true

discard g_timeout_add(50, anim, nil)

discard win.signal_connect("key-press-event", SIGNAL_FUNC(on_key_press), nil)
win.set_title("Test")
win.set_default_size(100,100)
win.show_all

main()

