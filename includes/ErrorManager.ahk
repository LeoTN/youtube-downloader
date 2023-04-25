#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

#Include "DownloadManager.ahk"
#Include "FileManager.ahk"
#Include "GetMethods.ahk"
#Include "GlobalVariables.ahk"
#Include "HotKeys.ahk"

; Beginning of the error related functions.

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