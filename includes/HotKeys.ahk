#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

#Include "GlobalVariables.ahk"

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
    manageURLFile()
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
        MsgBox("The file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
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
        MsgBox("The backup file does not exist !	`n`nIt was probably not generated yet.", "Error", "O Icon! T3")
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
        MsgBox("The blacklist file does not exist !	`n`nIt was probably not generated yet.", "Error", "O Icon! T3")
    }
}

Return

F3::
{
    result := MsgBox("Change format?", "Format change ", "OC Icon? T5")

    If (result = "Ok")
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
    Reload()
}
Return

+F4::
{
    result := MsgBox("The script will be terminated.", "Script termination ?", "OC Iconi T3")
    If (result = "Cancel")
    {
        Return
    }
    Else
    {
        ExitApp()
    }
}
Return