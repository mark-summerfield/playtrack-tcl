# Copyright © 2025 Mark Summerfield. All rights reserved.

package require about_form
package require config
package require config_form
package require mplayer
package require ref
package require ui

oo::singleton create App {
    variable Player
    variable Filename
    variable HistoryMenu
    variable BookmarkMenu
}

oo::define App constructor {} {
    ui::wishinit
    tk appname PlayTrack
    Config new ;# we need tk scaling done early
    set Player ""
    set Filename ""
    set HistoryMenu ""
    set BookmarkMenu ""
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
    set config [Config new]
    if {[set Filename [$config last_track]] ne ""} { my file_open }
}

oo::define App method make_ui {} {
    my prepare_ui
    set Player [Mplayer new]
    $Player set_debug 1
    puts "make_ui has_mplayer=[$Player has_mplayer] closed=[$Player closed] debug=[$Player debug]"
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
    const WIDTH 6
    ttk::frame .mf
    ttk::frame .mf.ctrl
    ttk::button .mf.ctrl.openButton -text Open… -underline 0 \
        -command [callback on_open] -width $WIDTH -compound left \
        -image [ui::icon document-open.svg $::ICON_SIZE]
    ttk::menubutton .mf.ctrl.historyButton -text History -underline 0 \
        -width $WIDTH -compound left \
        -image [ui::icon history.svg $::ICON_SIZE]
    set HistoryMenu [menu .mf.ctrl.historyButton.menu]
    .mf.ctrl.historyButton.menu add command -label "Remove Current" \
        -compound left -command [callback on_history_remove] 
        #-image [ui::icon ?.svg $::MENU_ICON_SIZE] ;# #TODO
    .mf.ctrl.historyButton.menu add command -label "Edit…" -compound left \
        -command [callback on_history_edit] -accelerator Ctrl+H
        #-image [ui::icon ?.svg $::MENU_ICON_SIZE] ;# TODO
    .mf.ctrl.historyButton.menu add separator
    .mf.ctrl.historyButton configure -menu .mf.ctrl.historyButton.menu
    ttk::menubutton .mf.ctrl.bookmarksButton -text B'marks -underline 0 \
        -width $WIDTH -compound left \
        -image [ui::icon bookmarks.svg $::ICON_SIZE]
    set BookmarkMenu [menu .mf.ctrl.bookmarksButton.menu]
    .mf.ctrl.bookmarksButton.menu add command -label "Add Current" \
        -compound left -accelerator F3 \
        -command [callback on_bookmarks_add] 
        #-image [ui::icon ?.svg $::MENU_ICON_SIZE] ;# #TODO
    .mf.ctrl.bookmarksButton.menu add command -label "Remove Current" \
        -compound left -command [callback on_bookmarks_remove] 
        #-image [ui::icon ?.svg $::MENU_ICON_SIZE] ;# #TODO
    .mf.ctrl.bookmarksButton.menu add command -label "Edit…" \
        -accelerator Ctrl+B -compound left \
        -command [callback on_bookmarks_edit] 
        #-image [ui::icon ?.svg $::MENU_ICON_SIZE] ;# TODO
    .mf.ctrl.bookmarksButton.menu add separator
    .mf.ctrl.bookmarksButton configure -menu .mf.ctrl.bookmarksButton.menu
    ttk::button .mf.ctrl.configButton -text Config… -underline 0 \
        -command [callback on_config] -width $WIDTH -compound left \
        -image [ui::icon preferences-system.svg $::ICON_SIZE]
    ttk::button .mf.ctrl.aboutButton -text About -underline 0 \
        -command [callback on_about] -width $WIDTH -compound left \
        -image [ui::icon about.svg $::ICON_SIZE]
    ttk::button .mf.ctrl.quitButton -text Quit -underline 0 \
        -command [callback on_quit] -width $WIDTH -compound left \
        -image [ui::icon quit.svg $::ICON_SIZE]
    # TODO
}

oo::define App method make_layout {} {
    const opts "-pady 3 -padx 3"
    pack .mf.ctrl -fill x -side top
    pack .mf.ctrl.openButton -side left {*}$opts
    pack .mf.ctrl.historyButton -side left {*}$opts
    pack .mf.ctrl.bookmarksButton -side left {*}$opts
    pack [ttk::frame .mf.ctrl.pad] -side left -fill x -expand 1 {*}$opts
    pack .mf.ctrl.configButton -side left {*}$opts
    pack .mf.ctrl.aboutButton -side left {*}$opts
    pack .mf.ctrl.quitButton -side left {*}$opts

    pack .mf -fill both -expand true
}

oo::define App method make_bindings {} {
    bind . <<MplayerPos>> [callback on_pos %d]
    bind . <<MplayerDebug>> [callback on_debug %d]
    bind . <F3> [callback on_bookmarks_add]
    bind . <Alt-a> {.mf.ctrl.aboutButton invoke}
    bind . <Alt-b> {
        tk_popup .mf.ctrl.bookmarksButton.menu \
            [expr {[winfo rootx .mf.ctrl.bookmarksButton]}] \
            [expr {[winfo rooty .mf.ctrl.bookmarksButton] + \
                   [winfo height .mf.ctrl.bookmarksButton]}]
    }
    bind . <Control-b> [callback on_bookmarks_edit]
    bind . <Alt-c> {.mf.ctrl.configButton invoke}
    bind . <Alt-h> {
        tk_popup .mf.ctrl.historyButton.menu \
            [expr {[winfo rootx .mf.ctrl.historyButton]}] \
            [expr {[winfo rooty .mf.ctrl.historyButton] + \
                   [winfo height .mf.ctrl.historyButton]}]
    }
    bind . <Control-h> [callback on_history_edit]
    bind . <Alt-o> {.mf.ctrl.openButton invoke}
    bind . <Alt-q> {.mf.ctrl.quitButton invoke}
    bind . <Escape> [callback on_quit]
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}

oo::define App method on_pos data {
    puts "on_pos: '$data'"
}

oo::define App method on_debug data {
    puts "on_debug: '$data'"
}

oo::define App method on_file_open {} {
    const filetypes {{{Audio Files} {.mp3 .ogg}}}
    set dir [file home]/Music
    set dir [expr {[file exists $dir] ? $dir : "[file home]/music]"}]
    set dir [expr {$Filename eq "" ? $dir : [file dirname $Filename]}]
    set filename [tk_getOpenFile -filetypes $filetypes -initialdir $dir]
    if {$filename ne ""} {
        set Filename $filename
        my file_open
    }
}

oo::define App method on_config {} {
    set config [Config new]
    set ok [Ref new false]
    set form [ConfigForm new $ok]
    tkwait window [$form form]
}

oo::define App method on_about {} {
    AboutForm new "Play tracks" \
        https://github.com/mark-summerfield/playtrack-tcl
}

oo::define App method on_quit {} {
    $Player close 
    puts "on_quit has_mplayer=[$Player has_mplayer] closed=[$Player closed] debug=[$Player debug]"
    set config [Config new]
    # TODO set last track, history, & bookmarks
    $config save
    exit
}

oo::define App method file_open {} {
    # TODO
    # - clear treeview
    # - load treeview with music files for this file's folder
    # - highlight this file
    # - update title bar
    puts "file_open $Filename"
    $Player play $Filename
}
