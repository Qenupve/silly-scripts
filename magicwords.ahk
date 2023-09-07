; This is an AutoHotKey script, it allows me to create custom hotkeys and autocompletion stuff.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Some global vars to keep track of info relevant to Win+Shift+Z hotkey
Global LastWinWidth := 1200
Global LastWinHeight := 800
Global LastWinID := 0
Global LastMonitor := 0

Global toggl := 0

::shruggie::¯\_(ツ)_/¯

::mymail::Richard.Origami@gmail.com

::mysig::
SendInput, ~Richard McWhirter{Enter}
SendInput, https://richard.mcwizard.club/professional/{Enter}
SendInput, {+}1-408-859-0804
return

::makedetails::
SendInput, <details><summary> ... </summary>{Enter}{Enter}</details>
return

::mkalias::
SendInput, alias ls='ls --color=auto --group-directories'{Enter}
SendInput, alias lah='ls -lah'{Enter}
SendInput, alias grep='grep --color=auto'{enter}
SendInput, export IP_RE='(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){{}3{}}'{enter}
SendInput, export IP_RE2='([0-9]{{}1,3{}}\.){{}3{}}[0-9]{{}1,3{}}'{enter}
return

; not sure I like this one anymore
;^SPACE::  Winset, AlwaysOnTop, , A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Move and resize terminal to 2nd monitor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; target terminal window size and pos from Window Spy:
;           x: -493	y: -2148	w: 1917	h: 2075     <-- I think this is the one I want
; Client:	x: 0	y: 0    	w: 1893	h: 2062

; Shift + Win + x to run
+#x::
{
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
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Move and resize windows to other monitors ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; target window size and pos from Window Spy:
;	        x: 1090	y: -1260	w: 1444	h: 1157     <-- this is the one you want
;Client:	x: 0	y: 0	    w: 1428	h: 1149

; Ctrl + Shift + Win + x to run
^+#x::
{
	; I have one ultrawide external monitor at home, two 1080p monitors in office.
	; You could also check for the resolutions of the monitors attached, or some
	; other differentiating factor, if you ever have the same number of monitors
	; but in different configurations.
	SysGet, MyMonitorCount, MonitorCount

	if (MyMonitorCount = 3)
	{
		; MsgBox, "Three monitors detected"
		WinMove, ahk_exe WindowsTerminal.exe,, 547, -1007, 1364, 965
		WinMove, ahk_exe OUTLOOK.EXE,, -1077, -1500, 1076, 1132
		WinMove, ahk_exe Teams.exe,, -1041, -655, 946, 1009
	}
	else if (MyMonitorCount = 2)
	{
		; MsgBox, "Two monitors detected"
		WinMove, ahk_exe WindowsTerminal.exe,, 1090, -1260, 1444, 1157
		WinMove, ahk_exe OUTLOOK.EXE,, -812, -1422, 1076, 1040
		WinMove, ahk_exe Teams.exe,, -792, -1069, 946, 1008
	}
	return
}


; Resize current window to fill most of the screen
; This is a bit buggy right now
; Shift + Win + z to run
+#z::
{
	;WinMove, A,,,, 1800, 1320
	WinGetPos, X, Y, W, H, A ; Get position & dimensions for A (active window)
	WinGet, ActiveID, ID, A
	ActiveMonitor := GetCurrentMonitor()
	
	SysGet, Mon, Monitor, %ActiveMonitor%
	
	MonWidth := MonRight - MonLeft
	MonHeight := MonBottom - MonTop
	
	SmallSide := Round(Min(MonWidth, MonHeight) * 0.9) ; make it take up roughly 90% of the monitor height
	LargeSide := Round(SmallSide * 1.5) 
	
	; Determine if monitor is portrait or landscape, set width & height accordingly
	if (MonWidth > MonHeight) {
		WinWidth := LargeSide
		WinHeight := SmallSide - Mod(SmallSide, 16) + 5 ; make it match Windows Terminal height increments
	} else {
		WinWidth := SmallSide
		WinHeight := LargeSide - Mod(LargeSide, 16) + 5 ; make it match Windows Terminal height increments
	}
	
	; if you accidentally activate this hotkey, you can immediately use it again to bounce it back to what it was
	if ( (LastWinWidth != WinWidth) or (LastWinHeight != WinHeight) ) and (LastWinID = ActiveID) and (LastMonitor = ActiveMonitor) {
		; nudge window so it fits on the screen, if it can
		if (X + LastWinWidth > MonRight) and (LastWinWidth < MonWidth)
			X := MonRight - LastWinWidth - 10
		if (Y + LastWinHeight > MonBottom) and (LastWinHeight < MonHeight)
			Y := MonBottom - LastWinHeight - 50
		
		WinMove, A,, %X%, %Y%, %LastWinWidth%, %LastWinHeight%
		LastWinHeight := H
		LastWinWidth := W
	} else {
		; nudge window so it fits on the screen, if it csan
		if ( X + WinWidth > MonRight) and (WinWidth < MonWidth) 
			X := MonRight - WinWidth - 10
		if ( Y + WinHeight > MonBottom ) and (WinHeight < MonHeight)
			Y := MonBottom - WinHeight - 50
		
		WinMove, A,, %X%, %Y%, %WinWidth%, %WinHeight%
		LastWinHeight := H
		LastWinWidth := W
		LastWinID := ActiveID
		LastMonitor := ActiveMonitor
	}
	return
}

; Get the monitor number that the active window is on
GetCurrentMonitor() {
	SysGet, numMonitors, MonitorCount
	WinGetPos, winX, winY, winWidth, winHeight, A
	winMidX := winX + winWidth / 2
	winMidY := winY + winHeight / 2
	Loop %numMonitors% {
		SysGet, monArea, Monitor, %A_Index%
		if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop) {
			return A_Index
		}
	}
}
