# Copyright © 2025 Mark Summerfield. All rights reserved.

proc humanize_secs secs {
    if {![set secs [expr {int(round($secs))}]]} {
        return "0s"
    }
    lassign [divmod $secs 3600] hours secs
    lassign [divmod $secs 60] mins secs
    set parts [list]
    if {$hours} { lappend parts "${hours}h" }
    if {$mins} { lappend parts "${mins}m" }
    if {$secs || ![llength $parts]} { lappend parts "${secs}s" }
    join $parts ""
}

proc divmod {n div} {
    set d [expr {$n / $div}]
    set m [expr {$n % $div}]
    list $d $m
}

proc humanize_filename filename {
    set home [file home]
    if {[string match $home/* $filename]} {
        set filename [string range $filename [string length $home/] end]
    }
    if {[string match {[Mm]usic*} $filename]} {
        set filename [string range $filename 6 end]
    }
    set parts [file split $filename]
    for {set i 1} {$i + 1 < [llength $parts]} {incr i} {
        if {[string match {*[0-9]} [set part [lindex $parts $i]]]} {
            ledit parts $i $i @
        }
    }
    ledit parts end end [string trimleft \
        [file rootname [lindex $parts end]] "0123456789"]
    set name [regsub {@+} [join $parts " / "] …]
    set name [regsub {\s+/\s+…\s+/\s+} $name " … "]
    set name [string trim [regsub -all {[-_.]} $name " "]]
    regsub -all {\s\s+} $name " "
}

proc humanize_trackname filename {
    set name [file tail [file rootname $filename]]
    set name [string trim [string trimleft $name "0123456789"]]
    string trim [regsub -all {[-_.]} $name " "]
}

proc get_music_dir filename {
    if {$filename ne ""} {
        set dir [file dirname $filename]
    } else {
        set home [file home]
        set dir $home/Music
        if {![file exists $dir]} {
            set dir $home/music
            if {![file exists $dir]} {
                set dir $home
            }
        }
    }
    return $dir
}

proc from_id s { regsub -all @ $s " " }
proc to_id s { regsub -all {\s} $s @ }
