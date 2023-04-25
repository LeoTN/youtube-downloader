#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

#Include "GlobalVariables.ahk"

/*
DEBUG SECTION
-------------------------------------------------
Hotkey to disable/enable debug mode.
*/
^+!F1::
{
    global booleanDebugMode
    If (booleanDebugMode = true)
    {
        booleanDebugMode := false
        MsgBox("Debug mode has been disabled.", "DEBUG MODE", "O Iconi 262144 T1.5")
    }
    Else If (booleanDebugMode = false)
    {
        booleanDebugMode := true
        MsgBox("Debug mode has been enabled.", "DEBUG MODE", "O Icon! 262144 T1.5")
    }
    Return
}

; Beginning of all standard script hotkeys.

; Main hotkey (start download).
^+!d::
{
    userStartDownload()
}
Return

; Second hotkey (collect URLs).
^+!s::
{
    saveSearchBarContentsToFile()
}
Return

; Will be help file in future.
F1::
{
    If (FileExist(URL_FILE_LOCATION))
    {
        manageURLFile()
    }
    Else
    {
        MsgBox("The  URL file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
    }
}
Return

; Every variation of F2 opens one of the three important .txt files.
; Opens only one instance each
; Will be reworked with the implementation of a GUI.
F2::
{
    Try
    {
        If (WinExist("YT_URLS.txt - Editor"))
        {
            WinActivate()
            Return true
        }
        Run(URL_FILE_LOCATION)
        Return true
    }
    Catch
    {
        MsgBox("The URL file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
    }
}
Return

+F2::
{
    Try
    {
        If (WinExist("YT_URLS_BACKUP.txt - Editor"))
        {
            WinActivate()
            Return true
        }
        Run(URL_BACKUP_FILE_LOCATION)
        Return true
    }
    Catch
    {
        MsgBox("The URL backup file does not exist !	`n`nIt was probably not generated yet.", "Error", "O Icon! T3")
    }
}
Return

^F2::
{
    Try
    {
        If (WinExist("YT_BLACKLIST.txt - Editor"))
        {
            WinActivate()
            Return true
        }
        Else If (FileExist(BLACKLIST_FILE_LOCATION))
        {
            Run(BLACKLIST_FILE_LOCATION)
            Return true
        }
        Else
        {
            ; Calls checkBlackListFile() in order to create a new blacklist file.
            checkBlackListFile("generateFile")
        }
    }
    Catch
    {
        MsgBox("The URL blacklist file does not exist !	`n`nIt was probably not generated yet.", "Error", "O Icon! T3")
    }
}

Return

F3::
{
    result := MsgBox("Change format?", "Format change ", "OC Icon? T5")

    If (result = "OK")
    {
        toggleDownloadFormat()
    }
    Else If (result = "Cancel")
    {
        ; Rework in the future
    }
    Else If (result = "Timeout")
    {
        ; Rework in the future
    }
}
Return

F4::
{
    ; Number in seconds.
    i := 3
    while (i > 0)
    {
        If (i = 1)
        {
            result := MsgBox("The script will be RELOADED in " . i " second.", "Script restart", "OC Icon! T1 Default2")
        }
        Else
        {
            result := MsgBox("The script will be RELOADED in " . i " seconds.", "Script restart", "OC Icon! T1 Default2")
        }
        i--
        If (result = "Cancel")
        {
            Return
        }
        Else If (result = "OK")
        {
            MsgBox("Script has been reloaded.", "Script status", "O Iconi T1.5")
            Reload()
        }
    }
    MsgBox("Script has been reloaded.", "Script status", "O Iconi T1.5")
    Reload()
}
Return

+F4::
{
    ; Number in seconds.
    i := 3
    while (i > 0)
    {
        If (i = 1)
        {
            result := MsgBox("The script will be TERMINATED in " . i " second.", "Script termination", "OC Icon! T1 Default2")
        }
        Else
        {
            result := MsgBox("The script will be TERMINATED in " . i " seconds.", "Script termination", "OC Icon! T1 Default2")
        }
        i--
        If (result = "Cancel")
        {
            Return
        }
        Else If (result = "OK")
        {
            MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
            ExitApp()
        }
    }
    MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
    ExitApp()
}
Return