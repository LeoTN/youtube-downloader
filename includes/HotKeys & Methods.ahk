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

+^!F1::
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
Hotkey(readConfigFile(7), (*) => userStartDownload())

; Second hotkey (collect URLs).
Hotkey(readConfigFile(8), (*) => saveSearchBarContentsToFile())

; Third hotkey (collect URLs from video thumbnail).
Hotkey(readConfigFile(9), (*) => saveVideoURLDirectlyToFile())

; GUI hotkey (opens GUI).
Hotkey(readConfigFile(10), (*) => Hotkey_openGUI())
; Hotkey support function to open the script GUI.
Hotkey_openGUI()
{
    static flipflop := true
    If (!WinExist("ahk_id " . mainGUI.Hwnd))
    {
        mainGUI.Show("w300 h200")
        flipflop := false
        Return
    }
    If (flipflop = false)
    {
        mainGUI.Hide()
        flipflop := true
    }
    Return
}

; Hotkey to termniate the script.
Hotkey(readConfigFile(11), (*) => terminateScriptPrompt(), "Off")

; Hotkey to reload the script.
Hotkey(readConfigFile(12), (*) => reloadScriptPrompt(), "Off")

; Hotkey to pause / continue the execution of the script.
Hotkey(readConfigFile(13), (*) => MsgBox("Not implemented yet"), "Off")

; Hotkey for clearing the URL file.
Hotkey(readConfigFile(14), (*) => clearURLFile())

/*
FUNCTION SECTION
-------------------------------------------------
*/

; Works together with GUI_MenuCheckHandler() to enable / disable certain hotkeys depending on
; the checkmark array generated by the scrip GUI.
toggleHotkey(pStateArray)
{
    stateArray := pStateArray
    static onOffArray := ["On", "On", "On"]

    Loop (stateArray.Length)
    {
        If (stateArray[A_Index] = false)
        {
            onOffArray.InsertAt(A_Index, "Off")
        }
        Else If (stateArray[A_Index] = true)
        {
            onOffArray.InsertAt(A_Index, "On")
        }
    }

    Hotkey(readConfigFile(11), (*) => terminateScriptPrompt(), onOffArray[1])
    Hotkey(readConfigFile(12), (*) => reloadScriptPrompt(), onOffArray[2])
    Hotkey(readConfigFile(13), (*) => MsgBox("Not implemented yet"), onOffArray[3])
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
    i := 4

    reloadScriptGUI := Gui(, "Script reload")
    textField := reloadScriptGUI.Add("Text", "r3 w260 x20 y40", "The script will be`n reloaded in " . i . " seconds.")
    textField.SetFont("s12")
    textField.SetFont("bold")
    progressBar := reloadScriptGUI.Add("Progress", "w280 h20 x10 y100", 0)
    buttonOkay := reloadScriptGUI.Add("Button", "Default w80 x60 y170", "Okay")
    buttonCancel := reloadScriptGUI.Add("Button", "w80 x160 y170", "Cancel")
    reloadScriptGUI.Show("w300 h200")

    buttonOkay.OnEvent("Click", (*) => Reload())
    buttonCancel.OnEvent("Click", (*) => reloadScriptGUI.Destroy())

    ; The try statement is needed to protect the code from crashing because
    ; of the destroyed GUI when the user presses cancel.
    Try
    {
        while (i >= 0)
        {
            ; Makes the progress bar feel smoother.
            Loop 20
            {
                progressBar.Value += 1.25
                Sleep(50)
            }

            If (i = 1)
            {
                textField.Text := "The script will be`n reloaded in " . i . " second."
            }
            Else
            {
                textField.Text := "The script will be`n reloaded in " . i . " seconds."
            }
            i--
        }
        textField.Text := "The script has been reloaded."
        Sleep(100)
        Reload()
        Return
    }
    Catch
    {
        Return
    }
}

terminateScriptPrompt()
{
    ; Number in seconds.
    i := 4

    terminateScriptGUI := Gui(, "Script termination")
    textField := terminateScriptGUI.Add("Text", "r3 w260 x20 y40", "The script will be`n terminated in " . i . " seconds.")
    textField.SetFont("s12")
    textField.SetFont("bold")
    progressBar := terminateScriptGUI.Add("Progress", "w280 h20 x10 y100 cRed backgroundBlack", 0)
    buttonOkay := terminateScriptGUI.Add("Button", "Default w80 x60 y170", "Okay")
    buttonCancel := terminateScriptGUI.Add("Button", "w80 x160 y170", "Cancel")
    terminateScriptGUI.Show("w300 h200")

    buttonOkay.OnEvent("Click", (*) => ExitApp())
    buttonCancel.OnEvent("Click", (*) => terminateScriptGUI.Destroy())

    ; The try statement is needed to protect the code from crashing because
    ; of the destroyed GUI when the user presses cancel.
    Try
    {
        while (i >= 0)
        {
            ; Makes the progress bar feel smoother.
            Loop 20
            {
                progressBar.Value += 1.25
                Sleep(50)
            }

            If (i = 1)
            {
                textField.Text := "The script will be`n terminated in " . i . " second."
            }
            Else
            {
                textField.Text := "The script will be`n terminated in " . i . " seconds."
            }
            i--
        }
        textField.Text := "The script has been terminated."
        Sleep(100)
        ExitApp()
        Return
    }
    Catch
    {
        Return
    }
}