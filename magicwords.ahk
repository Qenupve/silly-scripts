; This is an AutoHotKey script, it allows me to create custom hotkeys and autocompletion stuff.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

::mymail::Richard.Origami@gmail.com

::mysig::
SendInput, ~Richard McWhirter{Enter}
SendInput, https://richard.mcwizard.club/professional/{Enter}
SendInput, {+}1-408-859-0804
return

::makedetails::
SendInput, <details><summary> ... </summary>{Enter}{Enter}</details>
return

; not sure I like this one anymore
;^SPACE::  Winset, AlwaysOnTop, , A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Move and resize terminal to 2nd monitor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Shift + Win + x to run
+#x::

; target terminal window size and pos from Window Spy:
;           x: -493	y: -2148	w: 1917	h: 2075     <-- I think this is the one I want
; Client:	x: 0	y: 0    	w: 1893	h: 2062

SysGet, MyMonitorCount, MonitorCount
if MyMonitorCount > 1
{
    TermWidth = 1917 ; Target width, chosen to fit zpool iostat -vly
    TermHeight = 1000 ; placeholder value, actual will be set later
    TermX = 0
    TermY = 12
    
    SysGet, Mon2, MonitorWorkArea, 2
    Mon2Width := Mon2Right - Mon2Left
    Mon2Height := Mon2Bottom - Mon2Top
    TermX += Mon2Left
    Termy += Mon2Top
    
    ;MsgBox, Monitor 2`nWidth:`t%Mon2Width%`nHeight:`t%Mon2Height%
    ; This says Width = 5160 and Height = 2088 for my ultrawide
    ; That is 1.5 times the actual pixel count, maybe because the primary monitor is scaled 150%
    
    if TermWidth > %Mon2Width%
    {
        ; TODO placeholder, maybe change to mod something
        TermWidth := %Mon2Width% - 12 * 2
    }
    
    ; Terminal resizes in chunks, it snaps to heights = 73 + N * 28 on my *main* monitor (more on secondary monitor below)
    ; Let's maximize the height while keeping a buffer of (arbitrary) 12 & 5 pixels at the top & bottom of the screen
    UsableHeight := Mon2Height - 12 - 5 - 73
    ; Because my primary monitor is scaled 150%, terminal on 2nd screen has a weird 0.5 * 28 = 14 additional height?
    TermHeight := 73 + 14 + UsableHeight - Mod(UsableHeight, 28) ; not sure if it's faster to do (UsableHeight // 28) * 28
    
    ;MsgBox, Moving Windows Terminal.exe to x = %TermX%, y = %TermY%, width = %TermWidth%, height = %TermHeight%`nVariable height calculation is %TermHeight%, UsableHeight is %UsableHeight%
    WinMove, ahk_exe WindowsTerminal.exe,, %TermX%, %TermY%, %TermWidth%, %TermHeight%
    Sleep 0.1 ; when moving between monitors it takes a bit to figure out the scaling change...
    WinMove, ahk_exe WindowsTerminal.exe,,,, %TermWidth%, %TermHeight%
}
return