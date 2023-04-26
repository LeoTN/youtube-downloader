; NOTE : This is the main .ahk file which has to be started !!!
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

; Imports important functions and variables
; Sets the directory for all following files.
#Include "includes\"
#Include "DownloadManager.ahk"
#Include "FileManager.ahk"
#Include "ErrorManager.ahk"
#Include "GetMethods.ahk"
#Include "HotKeys.ahk"

; NOTE : This script currently only works with firefox as your default browser!

/*
DEBUG SECTION
-------------------------------------------------
Add debug hotkeys here.
*/

; Debug hotkey template.
F6::
{
    If (readConfigFile(1) = true)
    {
        ; Enter code below.
        createDefaultConfigFile(true)
        MsgBox("The config file has been reset.", "Information", "O Iconi T2")
    }
    Return
}

F7::
{
    If (readConfigFile(1) = true)
    {
        ; Enter code below.
        MsgBox(readConfigFile(2))
    }
    Return
}