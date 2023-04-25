#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off
; Imports important functions and variables
; NOTE : This is the main .ahk file which has to be started!
#Include "includes\"
#Include "DownloadManager.ahk"
#Include "FileManager.ahk"
#Include "ErrorManager.ahk"
#Include "GetMethods.ahk"
#Include "HotKeys.ahk"

; This script currently only works with firefox as your default browser!

; Add debug hotkeys here.
F5::
{
    MsgBox(checkBlackListFile("https://www.youtube.com/"))
}