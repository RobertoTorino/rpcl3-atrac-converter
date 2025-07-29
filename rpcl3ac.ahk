; YouTube: @game_play267
; Twitch: RR_357000
; X:@relliK_2048
; Discord:
; Atrac Converter
#SingleInstance Force
#NoEnv


tempDir := A_Temp . "\rpcl3_tools"
FileCreateDir, %tempDir%

; --- Install CLI ---
FileInstall, rpcl3_tools\vgmstream-cli.exe, %tempDir%\vgmstream-cli.exe, 1

; --- Install required DLLs ---
FileInstall, rpcl3_tools\avcodec-vgmstream-59.dll, %tempDir%\avcodec-vgmstream-59.dll, 1
FileInstall, rpcl3_tools\avformat-vgmstream-59.dll, %tempDir%\avformat-vgmstream-59.dll, 1
FileInstall, rpcl3_tools\avutil-vgmstream-57.dll, %tempDir%\avutil-vgmstream-57.dll, 1
FileInstall, rpcl3_tools\libatrac9.dll, %tempDir%\libatrac9.dll, 1
FileInstall, rpcl3_tools\libcelt-0061.dll, %tempDir%\libcelt-0061.dll, 1
FileInstall, rpcl3_tools\libcelt-0110.dll, %tempDir%\libcelt-0110.dll, 1
FileInstall, rpcl3_tools\libg719_decode.dll, %tempDir%\libg719_decode.dll, 1
FileInstall, rpcl3_tools\libmpg123-0.dll, %tempDir%\libmpg123-0.dll, 1
FileInstall, rpcl3_tools\libspeex-1.dll, %tempDir%\libspeex-1.dll, 1
FileInstall, rpcl3_tools\libvorbis.dll, %tempDir%\libvorbis.dll, 1


; Create GUI for AT3 to WAV converter
title := "RPCL3 Atrac Converter - " . Chr(169) . " " . A_YYYY . " - Philip"

Gui, +AlwaysOnTop
Gui, Font, s10 q5, Segoe UI

Gui, Add, GroupBox,              x10 y10 w400 h80, Input File
Gui, Add, Text,                  x20 y35, AT3 File:
Gui, Add, Edit, vAt3Path         x20 y55 w300 h25 ReadOnly
Gui, Add, Button, gBrowseAt3    x330 y54 w70 h25, Browse...

Gui, Add, GroupBox,              x10 y100 w400 h60, Actions
Gui, Add, Button, gConvertAt3    x20 y125 w100 h25, Convert to WAV
Gui, Add, Button, gClear        x130 y125 w100 h25, Clear
Gui, Add, Button, gExit         x240 y125 w100 h25, Exit

Gui, Add, GroupBox,              x10 y170 w400 h100, Status
Gui, Add, Edit, vStatus          x20 y190 w380 h70 ReadOnly VScroll

Gui, Show, w420 h280, %title%
return

BrowseAt3:
    FileSelectFile, selectedFile, 1, , Select AT3 file, Audio Files (*.at3)
    if (selectedFile != "") {
        GuiControl,, At3Path, %selectedFile%
        GuiControl,, Status, Selected: %selectedFile%
    }
return

ConvertAt3:
    GuiControlGet, at3Path,, At3Path
    at3Path := Trim(at3Path)

    if (at3Path = "") {
        GuiControl,, Status, Error: Please select an AT3 file first
        MsgBox, 48, No File Selected, Please browse and select an AT3 file first.
        return
    }

    SplitPath, at3Path, , dir, , name, ext
    output := dir . "\" . name . "_converted.wav"

    ; --- Path to executable ---
    exe := tempDir . "\vgmstream-cli.exe"

    ; --- Check fallback in uncompiled mode ---
    if (!FileExist(exe)) {
        ; In dev mode, fallback to local version
        exe := A_ScriptDir . "\rpcl3_tools\vgmstream-cli.exe"
    if (!FileExist(exe)) {
        status := "Error: Missing vgmstream-cli.exe`r`n"
        status .= "Please place vgmstream-cli.exe in: " . A_ScriptDir . "\rpcl3_tools\"
        GuiControl,, Status, %status%
        MsgBox, 48, Missing Tool, Missing vgmstream-cli.exe`n`nPlace the file in a 'rpcl3_tools' folder next to this script.
        return
        }
    }

    ; Check if input file exists
    if (!FileExist(at3Path)) {
        GuiControl,, Status, Error: Input file not found:`r`n%at3Path%
        MsgBox, 48, File Not Found, Input file not found:`n%at3Path%
        return
    }

    ; Show conversion info
    status := "Starting conversion...`r`n"
    status .= "Input: " . at3Path . "`r`n"
    status .= "Output: " . output . "`r`n"
    GuiControl,, Status, %status%

    ; Build and execute command
    cmd := """" . exe . """ """ . at3Path . """ -o """ . output . """"

    ; Show command for debugging
    GuiControl,, Status, %status%Running command:`r`n%cmd%`r`n

    ; Run conversion
    RunWait, %cmd%,, Hide UseErrorLevel

    ; Check results
    if ErrorLevel {
        status .= "`r`nConversion failed with error code: " . ErrorLevel
        GuiControl,, Status, %status%
        MsgBox, 48, Conversion Failed, Conversion failed with error code: %ErrorLevel%
    } else if FileExist(output) {
        status .= "`r`nSuccess! WAV file created:`r`n" . output
        GuiControl,, Status, %status%
        MsgBox, 64, Success, WAV file created successfully!`n%output%
    } else {
        status .= "`r`nConversion completed but output file not found"
        GuiControl,, Status, %status%
        MsgBox, 48, Error, Conversion completed but output file was not created.
    }
return

Clear:
    GuiControl,, At3Path,
    GuiControl,, Status, Ready - Select an AT3 file to convert
return

Exit:
GuiClose:
    ExitApp
return
