; NOTE : This is the main .ahk file which has to be started !!!
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

; Imports important functions and variables
; Sets the directory for all following files.
#Include "includes\"
#Include "ConfigFileManager.ahk"
#Include "DownloadManager.ahk"
#Include "FileManager.ahk"
#Include "ErrorManager.ahk"
#Include "GetMethods.ahk"
onInit()
#Include "HotKeys & Methods.ahk"

; Runs a list of commands when the script is launched.
onInit()
{
    ; Only called to check the config file status.
    readConfigFile()
}

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
    }
    Return
}

F7::
{
    If (readConfigFile(1) = true)
    {
        ; Enter code below
    }
    Return
}