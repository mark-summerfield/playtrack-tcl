# Copyright © 2025 Mark Summerfield. All rights reserved.

package require config
package require misc
package require ogg
package require ui

oo::singleton create App {
    variable Player
    variable TrackTree
    variable GotSecs
}

package require app_actions
package require app_ui

oo::define App constructor {} {
    ui::wishinit
    tk appname PlayTrack
    Config new ;# we need tk scaling done early
    set Player ""
    set GotSecs 0
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
    if {[set filename [$config last_track]] ne ""} {
        my maybe_new_dir $filename
    }
    focus $TrackTree
}

oo::define App method maybe_new_dir filename {
    set dir [file dirname [file normalize $filename]]
    set home [file home](?:/\[Mm\]usic)?/?
    if {[set dir_label [regsub -- $home $dir ""]] ne \
            [.mf.dirLabel cget -text]} {
        .mf.dirLabel configure -text $dir_label
        $TrackTree delete [$TrackTree children {}]
        my PopulateTrackTree [glob -directory $dir *.{mp3,ogg}]
    }
    catch {
        set name [to_id $filename]
        $TrackTree selection set $name
        $TrackTree see $name
    }
}

oo::define App method PopulateTrackTree filenames {
    set n 0
    foreach name [lsort -dictionary $filenames] {
        set secs [ogg::duration_in_secs $name]
        set secs [expr {$secs ? [humanize_secs $secs 1] : ""}]
        $TrackTree insert {} end -id [to_id $name] -text "[incr n]. " \
            -values [list [humanize_trackname $name] $secs]
    }
}

oo::define App method play_track filename {
    set filename [from_id $filename]
    set config [Config new]
    $config set_last_track $filename
    wm title . "[humanize_trackname $filename] — [tk appname]"
    my maybe_new_dir $filename
    set GotSecs 0
    $Player play $filename
    $config add_history $filename
    my populate_history_menu    
}
