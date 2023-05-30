#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

#Include "ConfigFileManager.ahk"
#Include "GUI.ahk"

/*
DEBUG SECTION
-------------------------------------------------
Hotkey to disable/enable debug mode.
*/

^+!F1::
{
    If (readConfigFile(1) = true)
    {
        editConfigFile(1, false)
        MsgBox("Debug mode has been disabled.", "DEBUG MODE", "O Iconi 262144 T1")
    }
    Else If (readConfigFile(1) = false)
    {
        editConfigFile(1, true)
        MsgBox("Debug mode has been enabled.", "DEBUG MODE", "O Icon! 262144 T1")
    }
    Return
}

; Beginning of all standard script hotkeys.

; Main hotkey (start download).
^+!d::
{
    userStartDownload()
    Return
}

; Second hotkey (collect URLs).
^+!s::
{
    saveSearchBarContentsToFile()
    Return
}

; Third hotkey (collect URLs from video thumbnail).
^+!f::
{
    saveVideoURLDirectlyToFile()
    Return
}

; GUI hotkey (opens GUI).
^+!g::
{
    static flipflop := true
    If (!WinExist("ahk_id " . myGUI.Hwnd))
    {
        myGUI.Show("w300 h200")
        flipflop := false
        Return
    }
    If (flipflop = false)
    {
        myGUI.Hide()
        flipflop := true
    }
    Return
}

clearURLFile()
{
    If (FileExist(readConfigFile(2)))
    {
        manageURLFile()
    }
    Else
    {
        MsgBox("The  URL file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
    }
    Return
}

; Opens only one instance each
openURLFile()
{
    Try
    {
        If (WinExist("YT_URLS.txt - Editor"))
        {
            WinActivate()
            Return true
        }
        Run(readConfigFile(2))
        Return true
    }
    Catch
    {
        MsgBox("The URL file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
    }
    Return
}

openURLBackUpFile()
{
    Try
    {
        If (WinExist("YT_URLS_BACKUP.txt - Editor"))
        {
            WinActivate()
            Return true
        }
        Run(readConfigFile(3))
        Return true
    }
    Catch
    {
        MsgBox("The URL backup file does not exist !	`n`nIt was probably not generated yet.", "Error", "O Icon! T3")
    }
    Return
}

openURLBlacklistFile(pBooleanShowPrompt := false)
{
    booleanShowPrompt := pBooleanShowPrompt
    If (booleanShowPrompt = true)
    {
        result := MsgBox("Do you really want to replace the current`n`nblacklist file with a new one ?", "Warning !", "YN Icon! T10")
        If (result = "Yes")
        {
            Try
            {
                If (!DirExist(A_WorkingDir . "\files\deleted"))
                {
                    DirCreate(A_WorkingDir . "\files\deleted")
                }
                SplitPath(readConfigFile(4), &outFileName)
                FileMove(readConfigFile(4), A_WorkingDir . "\files\deleted\" . outFileName, true)
                ; Calls checkBlackListFile() in order to create a new blacklist file.
                checkBlackListFile("generateFile", false)
                Return
            }
            Catch
            {
                ; Calls checkBlackListFile() in order to create a new blacklist file.
                checkBlackListFile("generateFile", false)
                Return
            }
        }
        Else
        {
            Return
        }
    }
    Try
    {
        If (WinExist("YT_BLACKLIST.txt - Editor"))
        {
            WinActivate()
            Return true
        }
        Else If (FileExist(readConfigFile(4)))
        {
            Run(readConfigFile(4))
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
    Return
}

openConfigFile()
{
    Try
    {
        If (WinExist("ytdownloader.ini - Editor"))
        {
            WinActivate()
            Return true
        }
        Else If (FileExist(configFileLocation))
        {
            Run(configFileLocation)
            Return true
        }
        Else
        {
            createDefaultConfigFile()
        }
    }
    Catch
    {
        MsgBox("The script's config file does not exist !	`n`nA fatal error has occured.", "Error", "O Icon! T3")
    }
    Return
}

; Saves a lot of coding by using a switch to determine which MsgBox has to be shown.
deleteFilePrompt(pFileName)
{
    fileName := pFileName
    result := MsgBox("Would you like to delete the " . fileName . " ?", "Delete " . fileName, "YN Icon! 8192 T10")
    If (result = "Yes")
    {
        If (!DirExist(A_WorkingDir . "\files\deleted"))
        {
            DirCreate(A_WorkingDir . "\files\deleted")
        }
        Try
        {
            Switch (fileName)
            {
                Case "URL-File":
                    {
                        c := 2
                        SplitPath(readConfigFile(2), &outFileName)
                        FileMove(readConfigFile(2), A_WorkingDir . "\files\deleted\" . outFileName)
                    }
                Case "URL-BackUp-File":
                    {
                        c := 3
                        SplitPath(readConfigFile(3), &outFileName)
                        FileMove(readConfigFile(3), A_WorkingDir . "\files\deleted\" . outFileName)
                    }
                Case "URL-Blacklist-File":
                    {
                        c := 4
                        SplitPath(readConfigFile(4), &outFileName)
                        FileMove(readConfigFile(4), A_WorkingDir . "\files\deleted\" . outFileName)
                    }
                Case "Downloaded Videos":
                    {
                        c := 5
                        MsgBox("Not implemented yet")
                        ; Possible in the future.
                    }
                Default:
                    {
                        terminateScriptPrompt()
                    }
            }
        }
        ; In case something goes wrong this will try to resolve the issue.
        Catch
        {
            If (FileExist(A_WorkingDir . "\files\deleted\" . outFileName) && FileExist(A_WorkingDir . "\files\" . outFileName))
            {
                result := MsgBox("The " . fileName . " was found in the deleted directory."
                    "`n`nDo you want to overwrite it ?", "Warning !", "YN Icon! T10")
                If (result = "Yes")
                {
                    FileDelete(A_WorkingDir . "\files\deleted\" . outFileName)
                    FileMove(readConfigFile(c), A_WorkingDir . "\files\deleted\" . outFileName)
                }
            }
            Else
            {
                MsgBox("The " . fileName . " does not exist !	`n`nIt was probably not generated yet.", "Error", "O Icon! T3")
            }
        }
    }
    Return
}

changeDownloadFormatPrompt()
{
    result := MsgBox("Change format?", "Format change ", "OC Icon? T5")

    If (result = "OK")
    {
        toggleDownloadFormat()
    }
    Return
}

reloadScriptPrompt()
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
    Return
}

terminateScriptPrompt()
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
    Return
}