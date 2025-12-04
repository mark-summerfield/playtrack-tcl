# Copyright © 2025 Mark Summerfield. All rights reserved.

package require about_form
package require config
package require config_form
package require ref
package require ui

oo::singleton create App {
}

oo::define App constructor {} {
    ui::wishinit
    tk appname PlayTrack
    Config new ;# we need tk scaling done early
    my make_ui
}

oo::define App method show {} {
    wm deiconify .
    set config [Config new]
    wm geometry . [$config geometry]
    raise .
    update
    after idle [callback on_startup]
}

oo::define App method on_startup {} {
}

oo::define App method make_ui {} {
    my prepare_ui
    my make_widgets
    my make_layout
    my make_bindings
}

oo::define App method prepare_ui {} {
    wm title . [tk appname]
    wm iconname . [tk appname]
    wm iconphoto . -default [ui::icon icon.svg]
    wm minsize . 320 180
}

oo::define App method make_widgets {} {
    set config [Config new]
    ttk::frame .mf
}

oo::define App method make_layout {} {
    const opts "-pady 3 -padx 3"

    pack .mf -fill both -expand true
}

oo::define App method make_bindings {} {
    bind . <Alt-a> [callback on_about]
    bind . <Alt-c> [callback on_config]
    bind . <Escape> [callback on_quit]
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}

oo::define App method on_config {} {
    set config [Config new]
    set ok [Ref new false]
    set form [ConfigForm new $ok]
    tkwait window [$form form]
}

oo::define App method on_about {} {
    AboutForm new PlayTrack \
        https://github.com/mark-summerfield/playtrack-tcl
}

oo::define App method on_quit {} {
    [Config new] save
    exit
}
