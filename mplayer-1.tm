# Copyright © 2025 Mark Summerfield. All rights reserved.

oo::singleton create Mplayer {
    variable Stream
    variable Filename
}

oo::define Mplayer constructor {} { my open }

oo::define Mplayer method open {} {
    set Stream [open "|mplayer -zoom -slave -idle -wid [winfo id .] \
                -input nodefault-bindings -noconfig all" r+]
    fconfigure $Stream -blocking 0 -buffering line
    fileevent $Stream readable [callback ReadPipe]
}

oo::define Mplayer method close {} {
    if {$Stream ne ""} { my stop ; flush $Stream ; set Stream "" }
}

oo::define Mplayer method replay {} { my Do "set_property time_pos 0" }

oo::define Mplayer method play filename {
    set Filename $filename
    my Do stop
    after 200        
    my Do "loadfile \"$Filename\""
}

oo::define Mplayer method pause {} { my Do pause }

oo::define Mplayer method stop {} { my Do stop }

oo::define Mplayer method volume percent { my Do "volume $percent" }

oo::define Mplayer method Do action { puts $Stream $action ; flush $Stream }

oo::define Mplayer method ReadPipe {} {
    set data [read $Stream]
    foreach line [split $data \n] {
        set line [string trim $line]
        if {[string match A:* $line]} {
            # TODO use regexp not split
            set fields [split $line]
            set pos [lindex $fields 3]
            set total [lindex $fields 6]
            event generate . <<MplayerPos>> -data {$pos $total}
        } else {
            event generate . <<MplayerDebug>> -data [string trim $line]
        }
    }
    if {[eof $Stream]} {
        fileevent $Stream readable {}
        close $Stream
        set Stream ""
    }
}
