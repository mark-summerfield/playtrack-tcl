# Copyright © 2025 Mark Summerfield. All rights reserved.

proc humanize_secs secs {
    set secs [expr {int(round($secs))}]
    # TODO show human values 3s/1m25s etc.
    return $secs
}

proc humanize_filename filename {
    # TODO
    return [file tail [file rootname $filename]]
}
