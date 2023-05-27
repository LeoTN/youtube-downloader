#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

#Include "ConfigFileManager.ahk"

; Beginning of the file manager functions.

; Save search bar contents to text file.
saveSearchBarContentsToFile()
{
    A_Clipboard := ""
    w := 1
    While (w = 1)
    {
        Send("^{l}")
        Sleep(100)
        Send("^{c}")

        If (ClipWait(2) = true)
        {
            clipboardContent := A_Clipboard
            Sleep(100)
            Send("{Escape}")
            Break
        }
    }
    If (FileExist(readConfigFile(2)))
    {

        writeToURLFile(clipboardContent)
    }
    Else
    {
        FileAppend("Made by Donnerbaer" . "`n", readConfigFile(2))
        writeToURLFile(clipboardContent)
    }
}

; Saves the video URL directly by hovering over the video thumbnail on the start page.
saveVideoURLDirectlyToFile()
{
    lastContent := A_Clipboard
    A_Clipboard := ""
    MouseClick("Right")
    ; Do not decrease values ! May lead to unstable performance.
    Sleep(100)
    ; Probably only works with German Firefox version.
    ; Will be language specific in the future.
    Send("k")
    Clipwait(0.35)
    If (lastContent = A_Clipboard || A_Clipboard = "")
    {
        MsgBox("No URL detected or same URL selected twice.", "Attention !", "O Icon! T1.5")
        Return
    }
    Else
    {
        clipboardContent := A_Clipboard
        If (FileExist(readConfigFile(2)))
        {
            writeToURLFile(clipboardContent)
        }
        Else
        {
            FileAppend("Made by Donnerbaer" . "`n", readConfigFile(2))
            writeToURLFile(clipboardContent)
        }
    }
    Return
}

writeToURLFile(pContent)
{
    content := pContent
    tmp := readFile(readConfigFile(2), true)
    ; Check if the URL already exists in the file.
    i := getCurrentURL(true, true)
    ; Content check loop
    Loop (i)
    {
        If (content = tmp[A_Index])
        {
            Return
        }
    }
    If (checkBlackListFile(content) = true)
    {
        Return
    }
    FileAppend(content . "`n", readConfigFile(2))
}

; Reads a specified file and creates an array object with it.
; Based on "`n" it will split the document.
; The parameter booleanCheckIfURL defines if you only want to include
; URLS and other links into the outcomming array.
; Returns the created array.
readFile(pFileLocation, pBooleanCheckIfURL := false)
{
    fileLocation := pFileLocation
    booleanCheckIfURL := pBooleanCheckIfURL
    Try
    {
        ; The loop makes sure, that only URLs are included into the array.
        URLs := FileRead(fileLocation)
        fileArray := []
        i := 1
        For k, v in StrSplit(URLs, "`n")
        {
            If (!InStr(v, "://") && booleanCheckIfURL = true)
            {
                Continue
            }
            If (v != "")
            {
                fileArray.InsertAt(i, v)
                i++
            }
        }
        Return fileArray
    }
    Catch
    {
        MsgBox("The file does not exist !	`n`nreadFile() could not be executed properly", "Error", "O Icon! T3")
        Return
    }
}

; Checks a given input if it exists on the blacklist.
; Returns true if a match was found and false otherwise.
checkBlackListFile(pItemToCompare)
{
    itemToCompare := pItemToCompare
    ; This content will be added to the new created blacklist file.
    ; You can add content to the ignore list by adding it to the .txt file
    ; or directly to the template array.
    templateArray := ["https://www.youtube.com/"]
    If (!FileExist(readConfigFile(4)))
    {
        result := MsgBox("Could not find blacklist file.`n`nDo you want to create one?", "Warning !", "YN Icon! T10")

        If (result = "Yes")
        {
            Try
            {
                ; Creates the blacklist file with the template.
                Loop templateArray.Length
                {
                    FileAppend(templateArray[A_Index] . "`n", readConfigFile(4))
                }
                checkBlackListFile(itemToCompare)
            }
            Catch
            {
                MsgBox("Could not create file !	`n`nCheck the config file for a valid path.", "Error", "O Icon! T3")
                Reload()
            }
        }
        Else If (result = "No" || "Timeout")
        {
            Return
        }
    }
    ; In case something has changed in the blacklist file.
    tmpArray := readFile(readConfigFile(4))
    If (!tmpArray.Has(1))
    {
        FileDelete(readConfigFile(4))
        Return checkBlackListFile(itemToCompare)
    }
    Loop templateArray.Length
    {
        If (templateArray[A_Index] != tmpArray[A_Index])
        {
            FileDelete(readConfigFile(4))
            Try
            {
                ; Creates the blacklist file with the template.
                Loop templateArray.Length
                {
                    FileAppend(templateArray[A_Index] . "`n", readConfigFile(4))
                }
            }
            Catch
            {
                MsgBox("Could not create file !	`n`nNo one knows why.", "Error", "O Icon! T3")
                Reload()
            }
        }
    }
    ; Compare the item if it matches with the blacklist.
    ; NOTE : This search method is not case sensitive and
    ; it does not search like InStr() !
    blacklistArray := readFile(readConfigFile(4))

    Loop blacklistArray.Length
    {
        If (itemToCompare = blacklistArray[A_Index])
        {
            Return true
        }
    }
    Return false
}

manageURLFile()
{
    result := MsgBox("Do you want to clear the URL file?`n`nA backup will be created anyways.", "Manage URL File", "4164 T10")

    If (result = "Yes")
    {
        Try
        {
            FileMove(readConfigFile(2), readConfigFile(3), true)
            Sleep(100)
            Reload()
        }
        Catch
        {
            MsgBox("The file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
            Reload()
        }

    }
    Else If (result = "No" || "Timeout")
    {
        Reload()
    }
}