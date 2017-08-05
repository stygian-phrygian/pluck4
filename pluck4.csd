<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
-+rtmidi=portmidi -Ma -odac
</CsOptions>
<CsInstruments>

sr      = 44100
ksmps   = 32
nchnls  = 2
0dbfs   = 1

gireverbwet       init 0.20
gireverbdry       init 1.00 - gireverbwet

                  ; assign all MIDI channels to instrument "Pluck"
                  massign   0, "Pluck"

; karplus strong synth
instr Pluck
                  ; receive midi input data
icps              cpsmidi
icpsoctave        init icps * 0.5
iamp              ampmidi 0dbfs
                  ; create amplitude envelope
kenv              mxadsr  0.01, .1, .9, 4.5
                  ; create karplus strong synth signals
                  ; applying the amplitude envelope
asig              pluck   0.3 * iamp * kenv, icps      , 60 / iamp, 0, 1
asigoctave        pluck   0.3 * iamp * kenv, icpsoctave, 60 / iamp, 0, 1
asig              = (0.5 * asig) + asigoctave
                  ; send respective dry and wet signals to out and "reverbsend"
                  outs   asig * gireverbdry, asig * gireverbdry
                  chnmix asig * gireverbwet, "reverbsend"
endin

; reverb fx bus (ie "reverbsend")
instr ReverbSend
asig              chnget "reverbsend"
aoutL, aoutR      reverbsc asig, asig, 0.95, 15000
                  outs aoutL, aoutR
                  chnclear "reverbsend"
endin

; keypress listener (controls recording playback)
instr KeyPressListener
krecordon init -1
kkey      sensekey
          ; flipflop (boolean not)  our krecordon variable
          ; only when space bar (ascii 32) is pressed
          if kkey == 32 then
            krecordon *= -1
            if krecordon == 1 then
              printks "Recording...\n", 0
              event "i", "MasterRecorder" , 0, -1 ; turn on instrument (our recording instrument)
            else
              printks "Stopping Recording...\n", 0
              inum nstrnum "MasterRecorder"      ; can't turn off a named instr (need instr #)
              event "i", -inum, 0, 0             ; turn it off
            endif
          endif
endin

instr +MasterRecorder
; generate a different filename each time instrument is called
itime         date
Stime         dates     itime
Syear         strsub    Stime, 20, 24
Smonth        strsub    Stime, 4, 7
Sday          strsub    Stime, 8, 10
iday          strtod    Sday
Shour         strsub    Stime, 11, 13
Smin          strsub    Stime, 14, 16
Ssec          strsub    Stime, 17, 19
Sfilename     sprintf  "%s_%s_%02d_%s_%s_%s.wav", Syear,Smonth,iday,Shour,Smin,Ssec
asigL, asigR  monitor
              fout Sfilename, 14, asigL, asigR
endin

; turn on the instruments
turnon nstrnum("ReverbSend")
turnon nstrnum("KeyPressListener")
</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>


