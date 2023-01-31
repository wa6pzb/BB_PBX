'
  pbx3
'
' 2.22283 - modified extension 2 ringing for PICAXE ringer
' 3.22297 - Version 3 start of refactoring
' 3.22303 - Fixed dialtone run on after quick hangup
'         - Added call_extension(ext) sub
'         - Added call_progress_tone variable to indicate a busy tone generator state
'         - Reworking rotary sub to work by extension
' 3.22304 - Added extension_enable array, cleaned up old variables, added comments
'         - Added call answer condition to main loop - call can be made from Ext 1 to 2 only now
'         - Added call count to the status log
' 3.22310 - Added PIXAXE ringing for extension 1
'         - Added number 4000 for extension 1
'         - Added cancel_call_extension_all sub
'         - Reduced flash time from 250 to 100ms
' 3.22311 - Began working on the Switch Fabric (relays)
'         - Added enable_extension sub for SLIC #1
' 3.22324 - Added enable_extension sub for SLIC #2
'         - Added set_path_a & set_path_b subs
'         - Added logging to progress tones
' 3.22338 - Added subs for enable_pstn_loop & disable_pstn_loop
'         - Added code to use PSTN module
'
' 3.23007 - Changed PSTN extension from 2000 to 1000 - basically flash hook now
'
' 3.23016 - Added IVR recording 0007.mp3 to SD Card and Sub play_ivr
'         - PSTN Module Ring Signal assigned
'         - Added to main loop get_ring_state Sub
  
' 3.23019 - Added DTMF pin assignments
'         - Added get_dtmf Sub
'
' 3.23030 - Added PSTN module loop current LC pin
'         - Cleaned up comments
'         - Added new code to get_dtmf to route call to extension 1 if dtmf detected
'         - Added sub get_pstn_hook_state
Sub pbx3
  header$=" BB_PBX-INFO-v3.23030- "
  m_loop=0 'Counter for the main loop
  pbx_uptime=0
  calls=0  'General call count
  
' General Variables
  call_progress_tone=0 ' If call_progress_tone is non-zero the tone generator is in use
  
  
' Setup Arrays for states of extension
  Dim hookstate(5)          'If true extension offhook
  Dim call_state(5)         'If true extension in a call
  Dim ring_state(5)         'If true extension is set to ring
  Dim voice_path(3)         'Voice path state by extension either 0 or 1
  Dim extension_enable(3)   'If true entension is connected to voice path
  
' Setup the pins for the hook monitoring for each extension
  Dim hook_pin(5)
  hook_pin(1) = 4 ' SLIC 1 is on Pin 4
  hook_pin(2) = 7 ' SLIC 2 is on Pin 7
  
  
' Assignment for SLIC I/O Pins
  SetPin 2, dout  'SLIC 1 Ringer RM
  SetPin 3, dout  'SLIC 1 Ringer F/R - Not USED
  SetPin 4, din   'SLIC 1 Hook SHR
  SetPin 5, dout  'SLIC 2 Ringer RM
  SetPin 6, dout  'SLIC 2 Ringer F/R - Not USED
  SetPin 7, din   'SLIC 2 Hook SHR
  
' Assignment for Audio Player I/O Pins
  SetPin 14, dout
  SetPin 15, dout
  SetPin 16, dout
  
' Assignment for Switch Fabric
  SetPin 17, dout ' SLIC #1 enable relay
  SetPin 18, dout ' SLIC #2 enable relay
  SetPin 21, dout ' Path A/B relays
  
' Assingments for PSTN Module
  SetPin 22, dout           ' PSTN Module Loop Switch Control LSC
  SetPin 23, din, PULLUP    ' PSTN Module Ring Signal RS
  SetPin 25, din            ' PSTN Module Loop Current LC
  
' Assignments for DTMF Module
  SetPin 24, din
  
  Dim nums(10) ' number array for pulse digits
  
' Initialize the SD Card audio play to silence
  play_silence
  
' Main PBX loop
  Do
    For Extension =  1 To 2
      get_hook_state
' Extension has gone off hook, so get number and process call
      If hookstate(extension)=1 And call_state(extension)=0 and call_progress_tone=0 and ring_state(extension)=0 Then
        Print Time$;header$;"Extension";extension;" offhook"
        enable_extension(extension)
        play_dailtone
        get_number
        process_call
      End If
' Extension has gone off hook from a ringing state
      If hookstate(extension)=1 And call_state(extension)=0 and call_progress_tone=1 and ring_state(extension)=1 Then
        Print Time$;header$;"Extension";extension;" answering call"
        cancel_call_extension_all ' changed 310
        enable_extension(extension) ' added 324
        ring_state(extension)=0
        call_state(extension)=1
        play_silence
        get_pstn_hook_state    'check that the external pstn line is still active
        If hookstate(3)=1 then
          set_path_a
        Else
          set_path_b          ' path b if extension to extension call
        end if
      End If
' Extension has gone off hook but the tone generator is busy, so continue to loop
      If hookstate(extension)=1 And call_state(extension)=0 and call_progress_tone=1 and ring_state(extension)=0 Then
        Print Time$;header$;"Extension";extension;" Can't Service Call - Tone Generator Busy"
        disable_extension(extension)
        flash(9)
      End if
' Extension has hung up
      If hookstate(extension)=0 And call_state(extension)=1 Then
        Print Time$;header$;"Extension"; extension;" End call to number"; number
        call_state(extension)=0
        disable_extension(extension)
        cancel_call_extension_all ' changed 310
        set_path_a                ' added 324
        disable_pstn_loop         ' added 338
        play_silence
        flash(9)
      End If
' Extension is on hook, so continue to loop
      If hookstate(extension)=0 And call_state(extension)=0 Then
        disable_extension(extension)
        flash(9)
      End If
'Extension is off hook in a call, so continue to loop
      If hookstate(extension)=1 And call_state(extension)=1 Then
        flash(9)
      End If
    Next Extension
'PSTN line check for ringing
    get_ring_state
    if ringstate=0 then
      Print Time$;header$;"PSTN Line ring detected"
      pause 4000     'let ring to get caller ID on phones
      enable_pstn_loop 'test only
      Print Time$;header$;"PSTN Line seized"
      pause 1000
      play_ivr ' test only
      get_dtmf
    End If
    
' Log activity every 10 minutes
    If m_loop=300 Then
      Print Time$;header$;"Status - Uptime";pbx_uptime;" Call Count";calls
      m_loop=0
      pbx_uptime = pbx_uptime + 2 ' based on 300 loops is 2 minutes
    End If
    m_loop=m_loop+1
  Loop
End Sub
'
Sub call_extension(ext)
  If ext = 0 Then Exit Sub
  If ext = 1 Then Pin(2) = 1 'Turn on PICAXE ringer for SLIC 1
  If ext = 2 Then Pin(5) = 1 'Turn on PICAXE ringer for SLIC 2
End Sub
'
Sub cancel_call_extension_all
  Pin(2) = 0 'Turn off PICAXE ringer for SLIC 1
  Pin(5) = 0 'Turn 0ff PICAXE ringer for SLIC 2
End Sub
'
Sub enable_extension(ext)
  If ext = 0 Then Exit Sub
  If ext = 1 Then Pin(17) = 1 'Turn on relay 1
  If ext = 2 Then Pin(18) = 1 'Turn on relay 4
End Sub
'
Sub disable_extension(ext)
  If ext = 0 Then Exit Sub
  If ext = 1 Then Pin(17) = 0 'Turn off relay 1
  If ext = 2 Then Pin(18) = 0 'Turn off relay 4
End Sub
'
Sub enable_pstn_loop
  Pin(22)=1
End Sub
'
Sub disable_pstn_loop
  Pin(22)=0
End Sub
'
Sub set_path_a
  Pin(21)=0
End Sub
'
Sub set_path_b
  Pin(21)=1
End Sub
'
Sub ring_line_1
  Pin(3)=1
  For r=1 To 40
    Pin(2)=1
    Pause 25
    Pin(2)=0
    Pause 25
  Next r
  Pin(3)=0
End Sub
'
Sub ring_line_2
  Pin(5)=1
End Sub
'
Sub cancel_ring_line_2
  Pin(5)=0
End Sub
'
Sub call_line_1
  Do
    ring_line_1
    Pause 4000
  Loop
End Sub
'
Sub call_line_2
  Print Time$;header$;"Extension";extension;" Calling number"; number
  ring_line_2
End Sub
'
Sub pin_check
  Do
    If Pin(25)=0 Then Print "Low" Else Print "High"
    Pause 100
  Loop
End Sub
'
Sub rotary2
  Timer =0
  digits=0
  number=0
  nums(0)=0:nums(1)=0:nums(2)=0:nums(3)=0:nums(4)=0
  needToPrint=0
  lastState=0
  trueState=0
  debounceDelay=10
  Do
    reading=Pin(hook_pin(extension))
    If Timer - lastStateChangeTime > 100 Then
      If needToPrint=1 Then
        nums(digits)=count Mod 10
        number=nums(1)*1000+nums(2)*100+nums(3)*10+nums(4)
        Print Time$;header$;"Extension"; extension;" Pulse Count";count Mod 10;" Number";number
        digits=digits+1
        needToPrint=0
        count=0
      EndIf
    EndIf
    If reading <> lastState Then
      lastStateChangeTime=Timer
    EndIf
    If Timer - lastStateChangeTime > 8 Then
      If reading <> trueState Then
        trueState=reading
        If trueState=1 Then
          count=count +1:needToPrint=1
        EndIf
      EndIf
    EndIf
    lastState=reading
    If digits=2 Then
      play_silence
      Exit Sub
    End If
'If digits=5 Then Exit Sub
    If Timer - lastStateChangeTime > 2500 And Pin(hook_pin(extension))=0 Then
      call_state(extension)=0
      play_silence 'Clears dialtone if hangup before dialing
      Exit Sub
    End If
    If Timer >= 8000 Then
      play_offhook
      Pause 5000
      Print Time$;header$;"call timeout"
      play_silence
      call_state(extension)=1
      Exit Sub
    EndIf
  Loop
End Sub
'
Sub flash(nbr)
  SetPin nbr, dout
  Pin(nbr)=1
  Pause 100
  Pin(nbr)=0
  Pause 100
End Sub
'
Sub get_hook_state
  hookstate(1)=Pin(4)
  hookstate(2)=Pin(7)
End Sub
'
Sub get_pstn_hook_state
  hookstate(3)=Pin(25)
End Sub
'
Sub get_ring_state
  ringstate=Pin(23)
End Sub
'
Sub get_number
  rotary2
End Sub
'
Sub get_dtmf
  Timer =0
  Do
    tone_detect=Pin(24)
    IF tone_detect = 1 and hookstate(1)=0 And call_state(1)=0 then
      Print Time$;header$;"DTMF Tone detected"
      Print Time$;header$;"Ringing Extension 1 for external call"
      calls=calls+1 ' increment calls to track call count
'call_state(1) = 1
      call_extension(1)
      play_ringing
      ring_state(1)=1
      exit sub
    End If
    If Timer >= 30000 Then
      Print Time$;header$;"DTMF detect timeout"
      pause 100
      play_silence
      disable_pstn_loop
      Print Time$;header$;"PSTN Line released"
      Exit Sub
    End If
  Loop
End Sub
'
Sub process_call
  If Pin(hook_pin(extension))=0 And call_state(extension)=0 Then Exit Sub
  If number=9000 Then
    Print Time$;header$;"Extension";extension;" in call to number";number
    calls=calls+1 ' increment calls to track call count
    call_state(extension) = 1
    Pause 2000
    play_ringing
    Pause 7000
    play_music
    Exit Sub
  End If
  If number=4000 Then
    Print Time$;header$;"Extension";extension;" in call to number";number
    calls=calls+1 ' increment calls to track call count
    call_state(extension) = 1
    call_extension(1)
    play_ringing    'added 324
    ring_state(1)=1
    Exit Sub
  End If
  If number=3000 Then
    Print Time$;header$;"Extension";extension;" in call to number";number
    calls=calls+1 ' increment calls to track call count
    call_state(extension) = 1
    call_extension(2)
    enable_extension(2)  ' added 324
    play_ringing ' added 324
    ring_state(2)=1
    Exit Sub
  End If
  If number=1000 Then
    Print Time$;header$;"Extension";extension;" in call to number";number
    calls=calls+1 ' increment calls to track call count
    call_state(extension) = 1
    enable_pstn_loop
    Exit Sub
  End If
  If number <> 3000 Or 9000 Then
    Print Time$;header$;"Extension";extension;" invalid extension";number
    call_state(extension) = 1
    play_reorder
    Pause 5000
    Print Time$;header$;"Extension";extension;" time out"
    play_silence
    Exit Sub
  End If
End Sub
'
Sub play_music
  Port(14,3)=6
  Print Time$;header$;"Progress Tone - Music"
  call_progress_tone=1
End Sub
'
Sub play_silence
  Port(14,3)=7
  Print Time$;header$;"Progress Tone - Silence"
  call_progress_tone=0
End Sub
'
Sub play_busy
  Port(14,3)=4
  Print Time$;header$;"Progress Tone - Busy"
  call_progress_tone=1
End Sub
'
Sub play_dailtone
  Port(14,3)=5
  Print Time$;header$;"Progress Tone - Dialtone"
  call_progress_tone=1
End Sub
'
Sub play_ringing
  Port(14,3)=2
  Print Time$;header$;"Progress Tone - Ringing"
  call_progress_tone=1
End Sub
'
Sub play_reorder
  Port(14,3)=3
  Print Time$;header$;"Progress Tone - Reorder"
  call_progress_tone=1
End Sub
'
Sub play_offhook
  Port(14,3)=1
  Print Time$;header$;"Progress Tone - Offhook Signal"
  call_progress_tone=1
End Sub
'
Sub play_ivr
  Port (14,3)=0
  Print Time$;header$;"Progress Tone - IVR"
  call_progress_tone=1
End Sub
'
