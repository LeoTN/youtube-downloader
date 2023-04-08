#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

; This script currently only works with firefox as your default browser!

openDownloadPage()
{
    WinActivate("ahk_class MozillaWindowClass")
    Run("https://de.onlinevideoconverter.pro/67/youtube-video-downloader?utm_source=pocket_mylist")

    w := 1
    while (w = 1)
    {
        currentTabName := WinGetTitle("ahk_class MozillaWindowClass")
        If (currentTabName = "YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
        {
            w := 0
            Sleep(500)
        }
    }
    Return true
}

startDownload(pURL)
{
    URL := pURL
    ; Focus text box
    Sleep(100)
    If (findTextBar() = true)
    {
        Sleep(100)
        Send URL
        ; Click start button
        Sleep(100)
        If (findStartButton() = true)
        {
            ; Wait for the website to process
            If (waitForDownloadButton() = true)
            {
                Sleep(500)
            }

            If (findDownloadButton() = true)
            {
                If (getCurrentURL(true) <= 0)
                {
                    result := MsgBox("Would you like to clear the URL file now?", "Download completed !", "33 T5")

                    If (result = "Yes")
                    {
                        closeBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
                        manageURLFile()
                        Reload()
                    }
                    Else If (result = "No")
                    {
                        closeBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
                        ExitApp()
                    }
                    Else If (result = "Timeout")
                    {
                        closeBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
                        manageURLFile()
                        Reload()
                    }
                }
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

    Return true
}

; Multiply timer value times sleep duration for the amount in seconds
wait8SecondsCanBeCancelled()
{
    timer := 0
    while (timer <= 800)
    {
        isDown := GetKeyState("Control")
        If (isDown = true)
        {
            Return true
        }
        Else
        {
            timer := timer + 1
            Sleep(10)
        }
    }
    Return false
}

closeBrowserTab(pTabName)
{

    TabName := pTabName
    WinActivate("ahk_class MozillaWindowClass")
    currentTabName := WinGetTitle("ahk_class MozillaWindowClass")
    ; Parse through 10 tabs and find the one with matching title
    Loop (10)
    {
        If (currentTabName = TabName)
        {
            Send("^{w}")
            Return
        }
        Else
        {
            Send("^{Tab}")
            Sleep(50)
            currentTabName := WinGetTitle("ahk_class MozillaWindowClass")
        }
    }
    Return
}

waitForDownloadButton()
{
    WinActivate("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(1248, 543)
    Sleep(100)
    w := 1
    while (w >= 1)
    {
        If (getPixelColorMouse() = "0xF07818")
        {
            Return true
        }
    }
}

findDownloadButton()
{
    WinActivate("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(1248, 543)
    Sleep(100)
    If (getPixelColorMouse() = 0xF07818) ; 0xF07818 is the color code of the orange button
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
    WinActivate("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(950, 348)
    Sleep(100)
    If (getPixelColorMouse() = 0xF07818) ; 0xF07818 is the color code of the orange button
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
    WinActivate("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(1200, 235)
    Sleep(100)
    ; 0xFFFFFF is the color code of the white text box

    Send("{Click}")
    Sleep(50)
    Send("^{a}")
    Sleep(50)
    Send("{Backspace}")
    Sleep(50)
    Return true
}

; Enter the desired format in caps (e.g. "MP3")
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

; Enter true to toggle flipflop
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

getPixelColorMouse()
{
    MouseGetPos(&MouseX, &MouseY)
    ButtonColor := PixelGetColor(MouseX, MouseY)
    Return ButtonColor
}

; Enter true for the currentArrays length or false to receive the item in the array
getCurrentURL(pBoolean)
{
    boolean := pBoolean
    static currentURL_Array := readURLFile()
    static tmpArray := [""]

    If (boolean = true)
    {
        Return currentURL_Array.Length - 1
    }
    Else If (getCurrentURL_Success(false) = true)
    {
        If (currentURL_Array.Length > 1 && boolean = false)
        {
            tmpArray[1] := currentURL_Array.Pop()
            Return tmpArray[1]
        }
        Else
        {
            Return
        }
    }
    Else If (getCurrentURL_Success(false) = false)
    {
        getCurrentURL_Success(true)
        Return tmpArray[1]
    }
}

; If the download fails, you have to call the getCurrentURL function again, but it would have deleted one link even though it was never downloaded
; This function prevents this error from happening, so that the seemingly deleted link will be reatached to the currentURL_Array
; Enter true, to trigger the flipflop or false to get the last state
getCurrentURL_Success(pBoolean)
{
    static flipflop := true
    boolean := pBoolean
    If (boolean = true)
    {
        flipflop := !flipflop
    }
    Return flipflop
}

; Save search bar contents to text file
saveSearchBarContentsToFile()
{
    fileLocation := A_ScriptDir . "\YT_URLS.txt"
    A_Clipboard := ""
    Send("^{l}")
    Sleep(100)
    Send("^{c}")
    Sleep(500)
    Send("{Tab}")
    ClipWait()
    FileAppend(A_Clipboard . "`n", fileLocation)
    Return fileLocation
}

; First array slot is empty ! Remember that.
readURLFile()
{
    urlFile := A_ScriptDir . "\YT_URLS.txt"
    urls := FileRead(urlFile)
    URLarray := [""]
    For k, v in StrSplit(urls, "`n")
    {
        If !InStr(v, "://")
        {
            Continue
        }
        URLarray.__New(v)
    }
    Return URLarray
}

manageURLFile()
{
    result := MsgBox("Do you want to clear the URL file?`n`nA backup will be created anyways.", "Manage Link File", "4164 T10")

    If (result = "Yes")
    {
        Try
        {
            FileMove(A_ScriptDir . "\YT_URLS.txt", A_ScriptDir . "\YT_URLS_BACKUP.txt", 1)
        }
        Catch
        {
            MsgBox("The file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
        }

    }
    Else If (result = "No")
    {

    }
    Else If (result = "Timeout")
    {

    }
}

userStartDownload()
{
    If FileExist(A_ScriptDir . "\YT_URLS.txt")
    {
        openDownloadPage()
        static i := getCurrentURL(true)
        Loop (i)
        {
            If (startDownload(getCurrentURL(false)) = false)
            {
                result := MsgBox("Something went wrong !`n`nWould you like to continue ?", "Download error", "21 T3")

                If (result = "Retry")
                {
                    getCurrentURL_Success(true)
                    startDownload(getCurrentURL(false))
                }
                Else If (result = "Cancel")
                {
                    ExitApp()
                }
                Else If (result = "Timeout")
                {
                    MsgBox("Restart of the script is recommended !", "Warning !", "O Icon! T3")
                }
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

; Main hotkey (start download)
^+!d::
{
    userStartDownload()
}

Return

; Second hotkey (collect URLs)
^+!s::
{
    saveSearchBarContentsToFile()
}
Return

F1::
{
    manageURLFile()
}
Return

F2::
{
    Try
    {
        Run(A_ScriptDir . "\YT_URLS.txt")
    }
    Catch
    {
        MsgBox("The file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
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