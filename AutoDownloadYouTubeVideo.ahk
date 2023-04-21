#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

; Specifies path for the .txt file which stores the URLs.
global URL_FILE_LOCATION := A_ScriptDir . "\YT_URLS.txt"
; Specifies path for the .txt file which stores the URL backup.
global URL_BACKUP_FILE_LOCATION := A_ScriptDir . "\YT_URLS_BACKUP.txt"
; Specifies path for the .txt file which stores the blacklist file.
global BLACKLIST_FILE_LOCATION := A_ScriptDir . "\YT_BLACKLIST.txt"
; Makes sure every function can open the firefox download instance. Receives an actual string in openDownloadPage().
global firefoxWindow := ""

; This script currently only works with firefox as your default browser!

; Checks if there are any common errors while starting a URL download.
checkForErrors()
{
    If (getPixelColorMouse(1200, 290, 0xED3833) = true)
    {
        ; Reload the page.
        Send("{Browser_Refresh}")
        ; Error_Red means that the download failed but no videoplayback page was opened.
        Return "Error_Red"
    }
    ; Wait for getPixelColorMouse() to execute. ; Wait for getPixelColorMouse() to execute.
    Sleep(3000)
    ; Checks for the videoplayback tab to appear.
    If (findBrowserTab("videoplayback – Mozilla Firefox") = true)
    {
        ; Download video manually ?!
        ; Error_Black means that the download failed and opened a videoplayback page.
        Return "Error_Black"
    }
    ; Checks for the videoplayback tab to appear (it is not always called "videoplayback")
    ; This method is unreliable and can cause erros while downloading !
    ; IMPORTANT NEEDS TO BE CHANGED WHEN FIREFOX USES ANY OTHER LANGUAGE THAN GERMAN !
    Else If (WinGetTitle(firefoxWindow) = "Neuer Tab – Mozilla Firefox" || WinGetTitle(firefoxWindow) = "Mozilla Firefox")
    {
        ; Error_Black_2 means that the download failed and opened a videoplayback page but you can not download anything.
        Return "Error_Black_2"
    }
    Else
    {
        Return "Error_None"
    }
}

; Tries to handle a given error while starting a download.
; In case no error is given the function will start a diagnosis.
; Returns true if an error was found and an action was made.
handleErrors(pErrorType := unset, pMaxAttempts := 2)
{
    If (IsSet(pErrorType))
    {
        error := pErrorType
        ; Reload the page.
        Send("{Browser_Refresh}")
        Sleep(500)
    }
    Else
    {
        error := unset
        error := checkForErrors()

        ; Wait for the checkForError method to complete before continuing downloading.
        while (IsSet(error) = false)
        {
            Sleep(500)
        }
    }
    maxAttempts := pMaxAttempts

    ; Error handling section.
    If (error = "Error_Red")
    {
        result := MsgBox("Failed to start downloading for an unknown reason !`n`nPress Cancel to skip the current URL !", "Download Error ! Remaining attempts : " . maxAttempts + 1, "RC IconX 8192 T5")

        If (result = "Retry")
        {
            getCurrentURL_DownloadSuccess(true)
            startDownload(getCurrentURL(false))
            Return handleErrors()
        }
        Else If (result = "Cancel")
        {
            ; Current URL will be skipped.
            Return true
        }
        Else If (result = "Timeout")
        {
            getCurrentURL_DownloadSuccess(true)
            startDownload(getCurrentURL(false))
            If (maxAttempts > 0)
            {
                ; This ensures that the function does not run infinetly
                ; The script tries the download several times and skips it after the maxAttempts number is reached ; The script tries the download several times and skips it after the maxAttempts number is reached
                Return handleErrors("Error_Red", maxAttempts - 1)
            }
            Else
            {
                Return true
            }
        }
    }
    Else If (error = "Error_Black")
    {
        result := MsgBox("Failed to start downloading for an unknown reason !`n`nPress Cancel to skip the current URL or continue and download the file manually !", "Download Error !", "OC IconX 8192 T15")
        If (result = "OK")
        {
            ; Manual download.
            MsgBox("Manual download is reqired.`n`nPress OK when you want to continue `nexecution of the script !", "Warning !", "O Icon! 8192") ; Will be automatic in future.

            finished := unset
            finished := handleErrors_skipURL()
            while (IsSet(finished) = false)
            {
                Sleep(500)
            }
            Return true
        }
        Else If (result = "Cancel")
        {
            finished := unset
            finished := handleErrors_skipURL()
            while (IsSet(finished) = false)
            {
                Sleep(500)
            }
            Return true
        }
        Else If (result = "Timeout")
        {
            finished := unset
            finished := handleErrors_skipURL()
            while (IsSet(finished) = false)
            {
                Sleep(500)
            }
            Return true
        }
    }
    Else If (error = "Error_Black_2")
    {
        WinClose(firefoxWindow)
        Sleep(500)
        openDownloadPage()
        Return true
    }
    Else If (error = "Error_None")
    {
        Return false
        ; Nothing here. Maybe in the future.
    }
}

; handleErrors() support function to avoid repetition.
; Returns true when it has finished.
handleErrors_skipURL()
{
    ; Current URL will be skipped and videoplayback tab closed.
    If (findBrowserTab("videoplayback – Mozilla Firefox", true) = true)
    {
        Sleep(100)
        If (findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox") = false)
        {
            openDownloadPage()
            Sleep(2000)
        }
    }
    Return true
}

userStartDownload()
{
    If FileExist(URL_FILE_LOCATION)
    {
        openDownloadPage()
        i := getCurrentURL(true, true)
        Loop (i)
        {
            ; Waits for startDownload() to finish
            result := unset
            result := startDownload(getCurrentURL(false))
            while (IsSet(result) = false)
            {
                Sleep(500)
            }

            ; Checks for common errors.
            result_1 := unset
            result_1 := handleErrors()
            while (IsSet(result_1) = false)
            {
                Sleep(500)
            }
            ; This means that there was an error found.
            If (result_1 = true)
            {
                Send("{Browser_Refresh}")
                Sleep(1000)
            }
        }
    }
    Else
    {
        saveSearchBarContentsToFile()
        Sleep(200)
        userStartDownload()
    }
}

; Starts the download and returns true if an URL download has started successfully.
startDownload(pURL)
{
    If (findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox") = true)
    {
        URL := pURL
        ; Refresh the page so that every button is on it's exact position.
        WinActivate(firefoxWindow)
        Sleep(100)
        ; Focus text box.
        If (findTextBar() = true)
        {
            Sleep(500)
            Send(URL)
            Sleep(500)
            ; Click start button.
            If (findStartButton() = true)
            {
                ; Wait for the website to process.
                If (waitForDownloadButton() = true)
                {
                    Sleep(500)
                    If (findDownloadButton() = true)
                    {
                        If (getCurrentURL(true) <= 0)
                        {
                            result := MsgBox("Would you like to close the browser instance now?", "Download completed !", "36 T5")

                            If (result = "Yes")
                            {
                                WinClose(firefoxWindow)
                                manageURLFile()
                                Reload()
                            }
                            Else If (result = "No")
                            {
                                findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
                                manageURLFile()
                                Reload()
                            }
                            Else If (result = "Timeout")
                            {
                                WinClose(firefoxWindow)
                                manageURLFile()
                                Reload()
                            }
                        }
                        Else
                        {
                            Return true
                        }
                    }
                    Else
                    {
                        Return false
                    }
                }
                Else
                {
                    Return false
                }
            }
            Else
            {
                Return false
            }
        }
        Else
        {
            Return false
        }
    }
    Else
    {
        openDownloadPage()
    }

}

; If necessary the function will open a new firefox window and the download tab within it.
openDownloadPage()
{
    firefoxLocation := A_ProgramFiles . "\Mozilla Firefox\firefox.exe"
    ; Just a random number
    static firefoxID := 123456789
    global firefoxWindow
    {
        If (!WinExist("ahk_id " . firefoxID))
        {
            Run(firefoxLocation)
            Sleep(500)
            firefoxID := WinGetID("A")
            firefoxWindow := "ahk_id " . firefoxID
        }
        ; Wait time depends on the system speed.
        Sleep(500)
        Try
        {
            Run("https://de.onlinevideoconverter.pro/67/youtube-video-downloader?utm_source=pocket_mylist")
        }
        Catch
        {
            Sleep(2000)
            Run("https://de.onlinevideoconverter.pro/67/youtube-video-downloader?utm_source=pocket_mylist")
        }
    }

    ; Waits for the download tab to appear.
    w := 1
    While (w = 1)
    {
        currentTabName := WinGetTitle(firefoxWindow)
        If (currentTabName = "YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
        {
            Sleep(500)
            Break
        }
    }
    Return true
}

; Multiply timer value times sleep duration for the amount in seconds.
wait8SecondsCanBeCancelled()
{
    timer := 800
    While (timer >= 0)
    {
        isDown := GetKeyState("Control")
        If (isDown = true)
        {
            Return true
        }
        Else
        {
            timer := timer - 1
            Sleep(10)
        }
    }
    Return false
}

; Waits for the download button to appear after the site has finished loading.
; Returns true, if the button is available and false after a set timeout timer.
waitForDownloadButton()
{
    WinActivate(firefoxWindow)
    ; Enter number in seconds.
    timeout := 10
    w := 1
    While (w = 1)
    {
        If (getPixelColorMouse(1248, 543, 0xF07818) = true)
        {
            Sleep(10)
            Return true
        }
        Else If (timeout <= 0)
        {
            Return false
        }
        Sleep(1000)
        timeout := timeout - 1
    }
}

; Enter the tab name you want to focus and as the second parameter wether you want to close it or not.
; The parameter parseAmount defines how many tabs the function will search before returning.
; forceFullParce declarates if you want to execute all parseAmount times or not. May lead to flashing browser screen !
; Returns true if a matching tab was found.
findBrowserTab(pTabName, pBooleanClose := false, pParseAmount := 20, pForceFullParse := false)
{
    ; Searches if the tab name includes parts of the firefox window name.
    If (InStr(pTabName, " – Mozilla Firefox", true))
    {
        tabName := pTabName
    }
    ; If the user only enters the "real" tab name without the firefox window name parts,
    ; they will be added afterwards so that the function runs properly.
    Else
    {
        tabName := pTabName . " – Mozilla Firefox"
    }
    booleanClose := pBooleanClose
    parseAmount := pParseAmount
    forceFullParse := pForceFullParse
    WinActivate(firefoxWindow)
    ; Currently only for firefox !
    originTab := WinGetTitle(firefoxWindow)
    ; Parse through tabs and find the one with matching title.
    Loop (parseAmount)
    {
        If (WinActive(firefoxWindow))
        {
            currentTabName := WinGetTitle(firefoxWindow)
            ; This condition checks if the loop already parsed every tab by comparing it to the very first tab.
            ; Once it reaches the origin tab the function will break the loop to stop parsing a second time.
            If (forceFullParse = false)
            {
                If (originTab = currentTabName && A_Index != 1)
                {
                    Break
                }
            }
            If (currentTabName = tabName && booleanClose = true)
            {
                Send("^{w}")
                Return true
            }
            Else If (currentTabName = tabName && booleanClose = false)
            {
                Return true
            }
            Else
            {
                Send("^{Tab}")
                Sleep(50)
            }
        }
        Else
        {
            WinActivate(firefoxWindow)
        }
    }
    Return false
}

findDownloadButton()
{
    WinActivate(firefoxWindow)
    ; 0xF07818 is the color code of the orange button.
    If (getPixelColorMouse(1248, 543, 0xF07818) = true)
    {
        Send("{Click}")
        Return true
    }
    Else
    {
        Return false
    }
}

findStartButton()
{
    WinActivate(firefoxWindow)
    ; 0xF07818 is the color code of the orange button.
    If (getPixelColorMouse(950, 348, 0xF07818) = true)
    {
        Send("{Click}")
        Return true
    }
    Else
    {
        Return false
    }
}

findTextBar()
{
    WinActivate(firefoxWindow)
    ; 0xFFFFFF is the color code of the white text box.
    Sleep(50)
    MouseMove(1200, 235)
    Sleep(100)

    Send("{Click}")
    Sleep(50)
    Send("^{a}")
    Sleep(50)
    Send("{Backspace}")
    Sleep(50)
    Return true
}

; Enter the desired format in caps (e.g. "MP3").
setDownloadFormat(pFormat)
{
    format := pFormat

    If (format = "MP3")
    {
        WinActivate(firefoxWindow)
        Sleep(10)
        MouseMove(1200, 290)
        Send("{Click}")
        Sleep(100)
        MouseMove(650, 335)
        Send("{Click}")
    }
    Else If (format = "MP4")
    {
        WinActivate(firefoxWindow)
        Sleep(10)
        MouseMove(1200, 290)
        Send("{Click}")
        Sleep(100)
        MouseMove(795, 335)
        Send("{Click}")
    }
}

; Enter true to toggle flipflop.
toggleDownloadFormat()
{
    static flipflop := false
    If (flipflop = true)
    {
        flipflop := !flipflop
        setDownloadFormat("MP4")
    }
    Else If (flipflop = false)
    {
        setDownloadFormat("MP3")
    }
}

; Enter coordinates to check a specific pixel or leave them blank to check the current one.
; If you want to you can specify a color to search for and depending on the success the function will return true or false.
; Otherwise the function will return the current pixels color.
; The variation defines how much a color can differ fromt the original one.
getPixelColorMouse(pMouseX := unset, pMouseY := unset, pColor := unset, pVariation := 10)
{
    WinActivate(firefoxWindow)
    If (IsSet(pMouseX) && IsSet(pMouseY))
    {
        MouseX := pMouseX
        MouseY := pMouseY
        Sleep(50)
        MouseMove(MouseX, MouseY)
    }
    If (IsSet(pColor))
    {
        color := pColor
        variation := pVariation
        Sleep(50)
        If (PixelSearch(&OutputX, &OutputY, MouseX, MouseY, MouseX, MouseX, color, variation) = true) ; Makes finding a color more easy by accepting multiple variations.
        {
            Return true
        }
        Else
        {
            Return false
        }
    }

    MouseGetPos(&MouseX, &MouseY)
    ButtonColor := PixelGetColor(MouseX, MouseY)
    Return ButtonColor
}

; Enter true for the currentArrays length or false to receive the item in the array.
; The second optional boolean defines wether you want to create the currentURL_Array or not.
getCurrentURL(pBooleanGetLength := false, pBooleanCreateArray := false)
{
    booleanGetLength := pBooleanGetLength
    booleanCreateArray := pBooleanCreateArray
    static tmpArray := [""]
    static currentURL_Array := [""]
    If (booleanCreateArray = true)
    {
        currentURL_Array := readFile(URL_FILE_LOCATION, true)
    }
    If (booleanGetLength = true)
    {
        Return currentURL_Array.Length
    }
    Else If (getCurrentURL_DownloadSuccess(false) = true)
    {
        If (currentURL_Array.Length >= 1 && booleanGetLength = false)
        {
            tmpArray[1] := currentURL_Array.Pop()
            ; Checks if the item is empty inside the URLarray.
            If (tmpArray[1] = "")
            {
                tmpArray[1] := currentURL_Array.Pop()
                Return tmpArray[1]
            }
            Else
            {
                Return tmpArray[1]
            }
        }
        Else
        {
            Return
        }
    }
    ; Returns the last content of the tmpArray (most likely because download failed).
    Else If (getCurrentURL_DownloadSuccess(false) = false)
    {
        getCurrentURL_DownloadSuccess(true)
        Return tmpArray[1]
    }
}

; getCurrentURL() support function.
; If the download fails, you have to call the getCurrentURL function again, but it would have deleted one link even though it was never downloaded.
; This function prevents this error from happening, so that the seemingly deleted link will be reatached to the currentURL_Array.
; Enter true, to trigger the flipflop or false to get the last state.
getCurrentURL_DownloadSuccess(pBoolean)
{
    static flipflop := true
    boolean := pBoolean
    If (boolean = true)
    {
        flipflop := !flipflop
    }
    Return flipflop
}

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

    If (FileExist(URL_FILE_LOCATION))
    {

        writeToURLFile(clipboardContent)
    }
    Else
    {
        FileAppend("Made by Donnerbaer" . "`n", URL_FILE_LOCATION)
        writeToURLFile(clipboardContent)
    }
}

writeToURLFile(pContent)
{
    content := pContent
    tmp := readFile(URL_FILE_LOCATION, true)
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
    FileAppend(content . "`n", URL_FILE_LOCATION)
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
    If (!FileExist(BLACKLIST_FILE_LOCATION))
    {
        result := MsgBox("Could not find blacklist file.`n`nDo you want to create one?", "Warning !", "YN Icon! T10")

        If (result = "Yes")
        {
            Try
            {
                ; Creates the blacklist file with the template.
                Loop templateArray.Length
                {
                    FileAppend(templateArray[A_Index] . "`n", BLACKLIST_FILE_LOCATION)
                }
                checkBlackListFile(itemToCompare)
            }
            Catch
            {
                MsgBox("Could not create file !	`n`nNo one knows why.", "Error", "O Icon! T3")
                Reload()
            }

        }
        Else If (result = "No")
        {
            Return ; REWORK?
        }
        Else If (result = "Timeout")
        {
            Return ; REWORK?
        }
    }
    ; In case something has changed in the blacklist file.
    tmpArray := readFile(BLACKLIST_FILE_LOCATION)
    If (!tmpArray.Has(1))
    {
        FileDelete(BLACKLIST_FILE_LOCATION)
        Return checkBlackListFile(itemToCompare)
    }
    Loop templateArray.Length
    {
        If (templateArray[A_Index] != tmpArray[A_Index])
        {
            FileDelete(BLACKLIST_FILE_LOCATION)
            Try
            {
                ; Creates the blacklist file with the template.
                Loop templateArray.Length
                {
                    FileAppend(templateArray[A_Index] . "`n", BLACKLIST_FILE_LOCATION)
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
    blacklistArray := readFile(BLACKLIST_FILE_LOCATION)

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
            FileMove(URL_FILE_LOCATION, A_ScriptDir . "\YT_URLS_BACKUP.txt", 1)
            Sleep(100)
            Reload()
        }
        Catch
        {
            MsgBox("The file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
            Reload()
        }

    }
    Else If (result = "No")
    {
        Reload()
    }
    Else If (result = "Timeout")
    {
        Reload()
    }
}

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

F2::
{
    Try
    {
        Run(URL_FILE_LOCATION)
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
        Run(URL_BACKUP_FILE_LOCATION)
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
        Run(BLACKLIST_FILE_LOCATION)
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

    }
    Else If (result = "Timeout")
    {

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
    ExitApp()
}
Return

F5::
{
    MsgBox(checkBlackListFile("https://www.youtube.com/"))
}