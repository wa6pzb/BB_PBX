'
  pbx2
'
Sub pbx2
  header$=" BB_PBX-INFO-v2.22268- "
  m_loop=0
  call_1=0
  Dim nums(10)
  SetPin 2, dout
  SetPin 3, dout
  SetPin 4, din
  SetPin 5, dout
  SetPin 6, dout
  SetPin 7, din
  SetPin 14, dout
  SetPin 15, dout
  SetPin 16, dout
  Do
    get_hook_state_line_1
    If hook_state_line_1=1 And call_1=0 Then
      Print Time$;header$;"Line 1 offhook"
      play_dailtone
      get_number
      process_call
    End If
    If hook_state_line_1=0 And call_1=1 Then
      Print Time$;header$;"Line 1 End call ext"; number
      call_1=0
      play_silence
      flash(9)
    End If
    If hook_state_line_1=0 And call_1=0 Then
      play_silence
      flash(9)
    End If
    If hook_state_line_1=1 And call_1=1 Then
      flash(9)
    End If
    If m_loop=1200 Then
      Print Time$;header$;"Active"
      m_loop=0
    End If
    m_loop=m_loop+1
  Loop
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
  Pin(6)=1
  For r=1 To 40
   If Pin(7)=1 Then
    Pin(6)=0
    Exit Sub
    End If
  Pin(5)=1
  Pause 25
  Pin(5)=0
  Pause 25
  Next r
  Pin(6)=0
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
Print Time$;header$;"Line 1 Calling call ext"; number
ring_line_2
Timer =0
  Do
    If Timer > 2000 Then
     Print Time$;header$;"Line 1 Calling call ext"; number
     ring_line_2
     If Pin(7)=1 Then Exit Sub
     Timer =0
    End If
    If Pin(4)=0 Then Exit Sub
    If Pin(7)=1 Then
     Print Time$;header$;"Line 1 connected to ext"; number
     Exit Sub
    End If
  Loop
End Sub
Sub hook
  Do
    If Pin(7)=1 Then Print "Off Hook" Else Print "On Hook"
    Pause 500
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
    reading=Pin(4)
    If Timer - lastStateChangeTime > 100 Then
      If needToPrint=1 Then
        Print count Mod 10;
        nums(digits)=count Mod 10
        number=nums(1)*1000+nums(2)*100+nums(3)*10+nums(4)
        Print number
        digits=digits+1
        needToPrint=0
        count=0
      EndIf
    EndIf
    If reading <> lastState Then
      lastStateChangeTime=Timer
    EndIf
    If Timer - lastStateChangeTime > 10 Then
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
    If Timer - lastStateChangeTime > 2500 And Pin(4)=0 Then
      call_1=0
      Exit Sub
    End If
    If Timer >= 8000 Then
      play_offhook
      Pause 5000
      Print Time$;header$;"call timeout"
      play_silence
      call_1=1
      Exit Sub
    EndIf
  Loop
End Sub
'
Sub flash(nbr)
  SetPin nbr, dout
  Pin(nbr)=1
  Pause 250
  Pin(nbr)=0
  Pause 250
End Sub
'
Sub get_hook_state_line_1
  hook_state_line_1=Pin(4)
End Sub
'
Sub get_number
  rotary2
End Sub
'
Sub process_call
  If Pin(4)=0 And call_1=0 Then Exit Sub
  If number=9000 Then
    Print Time$;header$;"Line 1 in call to ext";number
    call_1=1
    Pause 2000
    play_ringing
    Pause 7000
    play_music
    Exit Sub
  End If
  If number=2000 Then
    Print Time$;header$;"Line 1 in call to ext";number
    call_1=1
    call_line_2
    Exit Sub
  End If
  If number <> 2000 Or 9000 Then
    Print Time$;header$;"Line 1 invalid extension";number
    call_1=1
    play_reorder
    Pause 5000
    Print Time$;header$;"Line 1 time out"
    play_silence
    Exit Sub
  End If
End Sub
'
Sub play_music
  Port(14,3)=6
End Sub
'
Sub play_silence
  Port(14,3)=7
End Sub
'
Sub play_busy
  Port(14,3)=4
End Sub
'
Sub play_dailtone
  Port(14,3)=5
End Sub
'
Sub play_ringing
  Port(14,3)=2
End Sub
'
Sub play_reorder
  Port(14,3)=3
End Sub
'
Sub play_offhook
  Port(14,3)=1
End Sub
'
