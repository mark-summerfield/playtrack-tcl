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
    string trim [string trimleft [regsub -all {[-_.]} \
        [file tail [file rootname $filename]] " "] "0123456789"]
}
