#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

global URL_FILE_LOCATION := A_ScriptDir . "\YT_URLS.txt" ; Specifies path for the .txt file which stores the URLs.
global URL_BACKUP_FILE_LOCATION := A_ScriptDir . "\YT_URLS_BACKUP.txt" ; Specifies path for the .txt file which stores the URL backup.
; This script currently only works with firefox as your default browser!

; Checks if there are any common errors while starting a URL download.
checkForErrors()
{
    If (getPixelColorMouse(1200, 290, 0xED3833) = true)
    {
        Send("{Browser_Refresh}") ; Reload the page.
        Return "Error_Red" ; Error_Red means that the download failed but no videoplayback page was opened.
    }
    Sleep(2000) ; Wait for getPixelColorMouse() to execute.
    If (findBrowserTab("videoplayback – Mozilla Firefox", false) = true)
    {
        ; Download video manually ?!
        Return "Error_Black" ; Error_Black means that the download failed and opened a videoplayback page.
    }
    Else
    {
        Return "Error_None"
    }
}

; Tries to handle a given error while starting a download.
; In case no error is given the function will start a diagnosis.
; Returns true if an error was found and an action was made and the second handleErrors() call can be ignored.
handleErrors(pErrorType := unset, pMaxAttempts := 3)
{
    If (IsSet(pErrorType))
    {
        error := pErrorType
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
        result := MsgBox("Failed to start downloading for an unknown reason !`n`nPress Cancel to skip the current URL !", "Download Error ! Remaining attempts : " . maxAttempts, "RC IconX 8192 T1")

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
                getCurrentURL_DownloadSuccess(true)
                Return true
            }
        }
    }
    Else If (error := "Error_Black")
    {
        result := MsgBox("Failed to start downloading for an unknown reason !`n`nPress Cancel to skip the current URL or continue and download the file manually !", "Download Error !", "OC IconX 8192 T20")
        If (result = "OK")
        {
            ; Manual download.
            MsgBox("Manual download required !") ; Will be automatic in future.

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
    Else
    {
        Return false
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
        If (findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox", false) = false)
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
        ; openDownloadPage() ; CHANGED
        i := getCurrentURL(true, true)
        Loop (i)
        {
            startDownload(getCurrentURL(false))
            ; Checks for common errors.
            result := unset
            result := handleErrors("Error_Red")
            while (IsSet(result) = false)
            {
                Sleep(500)
            }
            If (result = true)
            {
                ; Deletes the URL which has to do with an error.
                getCurrentURL(false)
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
    URL := pURL
    Sleep(100)
    ; Focus text box.
    If (findTextBar() = true)
    {
        Sleep(100)
        ; Send(URL) ; CHANGED
        Sleep(100)
        ; Click start button.
        If (findStartButton() = true)
        {
            ; Wait for the website to process.
            If (waitForDownloadButton() = true)
            {
                Sleep(100)
                If (findDownloadButton() = true)
                {
                    If (getCurrentURL(true) <= 0)
                    {
                        result := MsgBox("Would you like to close the browser tab now?", "Download completed !", "36 T5")

                        If (result = "Yes")
                        {
                            findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox", true)
                            manageURLFile()
                            Reload()
                        }
                        Else If (result = "No")
                        {
                            findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox", false)
                            manageURLFile()
                            Reload()
                        }
                        Else If (result = "Timeout")
                        {
                            findBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox", true)
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
                    ; MsgBox("Failed at 4") ; REMOVE
                    Return false
                }
            }
            Else
            {
                ; MsgBox("Failed at 3") ; REMOVE
                Return false
            }
        }
        Else
        {
            ; MsgBox("Failed at 2") ; REMOVE
            Return false
        }
    }
    Else
    {
        ; MsgBox("Failed at 1") ; REMOVE
        Return false
    }
}

; startDownload() support function.
; This flipflop is used skip one execution of the handleErrors() method in order to complete one cycle of the loop.
startDownload_skipOneErrorHandling(pBoolean)
{
    static flipflop := true
    boolean := pBoolean
    If (boolean = true)
    {
        flipflop := !flipflop
    }
    Return flipflop
}

openDownloadPage()
{
    firefoxLocation := A_ProgramFiles . "\Mozilla Firefox\firefox.exe"
    Try
    {
        WinActivate("ahk_class MozillaWindowClass")
        Sleep(100)
        Run("https://de.onlinevideoconverter.pro/67/youtube-video-downloader?utm_source=pocket_mylist")
    }
    Catch
    {
        Run(firefoxLocation)
        Sleep(500) ; Wait time depends on the system speed.
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

    w := 1
    While (w = 1)
    {
        currentTabName := WinGetTitle("ahk_class MozillaWindowClass")
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
    Return true
    WinActivate("ahk_class MozillaWindowClass")
    timeout := 4 ; Enter number in seconds. ; CHANGED
    w := 1
    While (w = 1)
    {
        If (getPixelColorMouse(1248, 543) = "0xF07818")
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
; Returns true if a matching tab was found
findBrowserTab(pTabName, pBooleanClose)
{
    TabName := pTabName
    booleanClose := pBooleanClose
    WinActivate("ahk_class MozillaWindowClass") ; Currently only for firefox !
    currentTabName := WinGetTitle("ahk_class MozillaWindowClass")
    ; Parse through 20 tabs and find the one with matching title.
    Loop (20)
    {
        If (WinActive("ahk_class MozillaWindowClass"))
        {
            If (currentTabName = TabName && booleanClose = true)
            {
                Send("^{w}")
                Return true
            }
            Else If (currentTabName = TabName && booleanClose = false)
            {
                Return true
            }
            Else
            {
                Send("^{Tab}")
                Sleep(50)
                currentTabName := WinGetTitle("ahk_class MozillaWindowClass")
            }
        }
        Else
        {
            WinActivate("ahk_class MozillaWindowClass")
        }
    }
    Return
}

findDownloadButton()
{
    Return true
    WinActivate("ahk_class MozillaWindowClass")

    If (getPixelColorMouse(1248, 543, 0xF07818) = true) ; 0xF07818 is the color code of the orange button.
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
    Return true
    WinActivate("ahk_class MozillaWindowClass")

    If (getPixelColorMouse(950, 348, 0xF07818) = true) ; 0xF07818 is the color code of the orange button.
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
    Return true
    WinActivate("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(1200, 235)
    Sleep(100)
    ; 0xFFFFFF is the color code of the white text box.

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
        WinActivate("ahk_class MozillaWindowClass")
        Sleep(10)
        MouseMove(1200, 290)
        Send("{Click}")
        Sleep(100)
        MouseMove(650, 335)
        Send("{Click}")
    }
    Else If (format = "MP4")
    {
        WinActivate("ahk_class MozillaWindowClass")
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
    WinActivate("ahk_class MozillaWindowClass")
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
getCurrentURL(pBooleanGetLength, pBooleanCreateArray := false)
{
    booleanGetLength := pBooleanGetLength
    booleanCreateArray := pBooleanCreateArray
    static tmpArray := [""]
    static currentURL_Array := [""]
    If (booleanCreateArray = true)
    {
        currentURL_Array := readURLFile()
    }
    If (booleanGetLength = true)
    {
        Return currentURL_Array.Length
    }
    Else If (getCurrentURL_DownloadSuccess(false) = true)
    {
        If (currentURL_Array.Length >= 1 && booleanGetLength = false)
        {
            MsgBox("AAl")
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
            Send("{Tab}")
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
    tmp := readURLFile()
    ; Check if the URL already exists in the file.
    i := getCurrentURL(true, true)

    Loop (i)
    {
        If (content = tmp[A_Index])
        {
            Return
        }
    }
    FileAppend(content . "`n", URL_FILE_LOCATION)
}

; Reads the URL.txt file and creates an array object with it.
readURLFile()
{
    Try
    {
        ; The loop makes sure, that only URLs are included into the array.
        URLs := FileRead(URL_FILE_LOCATION)
        URLarray := []
        ; URLarray.RemoveAt(1)
        i := 1
        For k, v in StrSplit(URLs, "`n")
        {
            If !InStr(v, "://")
            {
                Continue
            }
            URLarray.InsertAt(i, v)
            i := i + 1
        }
        Return URLarray
    }
    Catch
    {
        MsgBox("The file does not exist !	`n`nreadURLFile() could not be executed properly", "Error", "O Icon! T3")
        Return
    }
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

/* DEBUG
F5::
{
    findBrowserTab("videoplayback – Mozilla Firefox", true)
}

F6::
{
    If (getPixelColorMouse(950, 348, 0xF07818, 20) = true)
    {
        MsgBox("Checkste?")
    }
}

F7::
{
    MsgBox(getPixelColorMouse())
}

F8::
{
    MouseGetPos(&MouseX, &MouseY)
    If (getPixelColorMouse(MouseX, MouseY, 0xF07818, 20) = true)
    {
        MsgBox("erfolg")
    }
}

F9::
{
    MsgBox(checkForErrors())
}
*/
