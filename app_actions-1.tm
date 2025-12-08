# Copyright © 2025 Mark Summerfield. All rights reserved.

package require about_form
package require config_form
package require ref

oo::define App method on_file_open {} {
    set filename [[Config new] last_track]
    const filetypes {{{Audio Files} {.mp3 .ogg}}}
    set dir [file home]/Music
    set dir [expr {[file exists $dir] ? $dir : "[file home]/music]"}]
    set dir [expr {$filename eq "" ? $dir : [file dirname $filename]}]
    set filename [tk_getOpenFile -parent . -filetypes $filetypes \
                  -initialdir $dir]
    if {$filename ne ""} {
        my play_track $filename
    }
}

oo::define App method on_play_prev {} {
    if {[set prev [$TrackView prev [$TrackView selection]]] ne ""} {
        $TrackView selection set $prev
        $TrackView see $prev
        my play_track $prev
    }
}

oo::define App method on_play_replay {} { $Player replay }

oo::define App method on_play_pause_resume {} { $Player pause }

oo::define App method on_play {} {
    if {[set selection [$TrackView selection]] ne ""} {
        my play_track $selection
    }
}

oo::define App method on_play_next {} {
    if {[set next [$TrackView next [$TrackView selection]]] ne ""} {
        $TrackView selection set $next
        $TrackView see $next
        my play_track $next
    }
}

oo::define App method on_volume_down {} {
    if {$Player ne ""} { $Player volume_down }
}

oo::define App method on_volume_up {} {
    if {$Player ne ""} { $Player volume_up }
}

oo::define App method on_history_remove {} {
    puts on_history_remove ;# TODO
}

oo::define App method on_history_edit {} {
    puts on_history_edit ;# TODO
}

oo::define App method on_bookmarks_add {} {
    puts on_bookmarks_add ;# TODO
}

oo::define App method on_bookmarks_remove {} {
    puts on_bookmarks_remove ;# TODO
}

oo::define App method on_bookmarks_edit {} {
    puts on_bookmarks_edit ;# TODO
}

oo::define App method on_config {} {
    set config [Config new]
    set ok [Ref new 0]
    set debug [Ref new [$Player debug]]
    set form [ConfigForm new $ok $debug]
    tkwait window [$form form]
    if {[$ok get]} {
        $Player set_debug [$debug get]
    }
}

oo::define App method on_about {} {
    AboutForm new "Play tracks" \
        https://github.com/mark-summerfield/playtrack-tcl
}

oo::define App method on_quit {} {
    $Player close 
    [Config new] save
    exit
}
