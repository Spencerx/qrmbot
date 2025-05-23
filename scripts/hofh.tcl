# Maintain a quote list across channels
#
# 2-clause BSD license.
# Copyright (c) 2018, 2019 molo1134@github. All rights reserved.

bind pub - !addhofh h_addquote
bind pub - !hofh h_pubquote
bind pub - !hofhsearch h_pubquotesearch

set hofhfile "scripts/hofhlist.txt"

proc h_addquote { nick uhost hand chan arg } {
  global hofhfile

  if { [file exists $hofhfile] } {
    set qf [open $hofhfile a]
  } else {
    set qf [open $hofhfile w]
  }

  set entry [list]
  lappend entry "$arg"

  puts $qf $entry

  putmsg "$nick" "added hofh: $arg"

  close $qf
}


proc h_pubquote { nick uhost hand chan arg } {
  global hofhfile

  if { [file exists $hofhfile] } {

    set qf [open $hofhfile r]
    set done 0

    set fd [open "|wc -l $hofhfile" r]
    while {![eof $fd]} {
      scan [gets $fd] " %d " tmp
      if {[eof $fd]} {break}
    }
    close $fd

    set i 0

    if { [string trim "$arg"] == "" } {
      set j [rand $tmp]
      #putmsg "$nick" "picked hofh [expr $j + 1] of $tmp"
    } else {
      set j "$arg"
      if { ( $j >= 1 ) && ( $j <= $tmp ) } {
        #putmsg "$nick" "displaying hofh $j of $tmp"
        incr j -1
      } else {
        putmsg "$nick" "valid hofh number from 1 to $tmp"
        return
      }
    }

    while { $j >= $i } {

      set line [gets $qf]
      incr i

    }

    close $qf

    putchan $chan "[lindex $line 0]"


  } else {
    putmsg "$nick" "error, $hofhfile not found!"
  }
}


proc h_pubquotesearch { nick uhost hand chan arg } {
    global hofhfile

    set newarg [string trim "$arg"]

    if { [string length "$newarg"] < 3 } {
	putmsg "$nick" "error, search string too short"
    } elseif { [file exists $hofhfile] } {
        set qf [open $hofhfile r]

        set fd [open "|wc -l $hofhfile" r]
        while {![eof $fd]} {
          scan [gets $fd] " %d " tmp
          if {[eof $fd]} {break}
        }
        close $fd

        set newarg [string tolower "$newarg"]

        set i 0
        set j 0

        while {$i < $tmp} {
            set line [gets $qf]
            if { [string first "$newarg" [string tolower [lindex $line 0] ] ] != -1 } {
                putmsg "$nick" "found hofh [expr $i+1]:"
                putmsg "$nick" "[lindex $line 0]"
                incr j
            }
            incr i
        }

	putmsg "$nick" "found $j hit(s) for $arg"

    } else {
        putmsg "$nick" "error, $hofhfile not found!"
    }
}

putlog "hofh loaded."
