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
        if (currentTabName = "YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
        {
            w := 0
            Sleep 1000
        }
    }
    Return true
}

startDownload(pURL)
{
    URL := pURL
    ; Focus text box
    Sleep(100)
    if (findTextBar() = true)
    {
        Sleep(100)
        Send URL
        ; Click start button
        Sleep(100)
        if (findStartButton() = true)
        {
            ; Wait for the website to process
            if (waitForDownloadButton() = true)
            {
                Sleep(500)
            }

            if (findDownloadButton() = true)
            {
                if (getCurrentURL(true) <= 0)
                {
                    result := MsgBox("Would you like to restart the script now?", "Download completed !", "33 T5")

                    if (result = "Yes")
                    {
                        closeBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
                        manageURLFile()
                        Reload()
                    }
                    else if (result = "No")
                    {
                        ExitApp()
                    }
                    else if (result = "Timeout")
                    {
                        closeBrowserTab("YouTube Downloader Kostenlos Online❤️ - YouTube-Videos Herunterladen – Mozilla Firefox")
                        manageURLFile()
                        Reload()
                    }
                }
            }

        }
        else
        {
            Return false
        }
    }
    else
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
        if (isDown = true)
        {
            Return true
        }
        else
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
        if (currentTabName = TabName)
        {
            Send("^{w}")
            Return
        }
        else
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
    WinActivate ("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(1248, 543)
    Sleep(100)
    i := 1
    while (i >= 1)
    {
        if (getPixelColorMouse() = "0xF07818")
        {
            Return true
        }
    }
}

findDownloadButton()
{
    WinActivate ("ahk_class MozillaWindowClass")
    Sleep(50)
    MouseMove(1248, 543)
    Sleep(100)
    if (getPixelColorMouse() = 0xF07818) ; 0xF07818 is the color code of the orange button
    {
        Send("{Click}")
        Return true
    }
    else
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
    if (getPixelColorMouse() = 0xF07818) ; 0xF07818 is the color code of the orange button
    {
        Send("{Click}")
        Return true
    }
    else
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

    if (format = "MP3")
    {
        WinActivate ("ahk_class MozillaWindowClass")
        Sleep(10)
        MouseMove(1200, 290)
        Send("{Click}")
        Sleep(100)
        MouseMove(650, 335)
        Send("{Click}")
    }
    else if (format = "MP4")
    {
        WinActivate ("ahk_class MozillaWindowClass")
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
    if (flipflop = true)
    {
        flipflop := !flipflop
        setDownloadFormat("MP4")
    }
    else if (flipflop = false)
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

    if (boolean = true)
    {
        Return currentURL_Array.Length - 1
    }
    else if (getCurrentURL_Success(false) = true)
    {
        if (currentURL_Array.Length > 1 && boolean = false)
        {
            tmpArray[1] := currentURL_Array.Pop()
            Return tmpArray[1]
        }
        else
        {
            Return
        }
    }
    else if (getCurrentURL_Success(false) = false)
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
    if (boolean = true)
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
    result := MsgBox("Do you want to clear the link file?`n`nA backup will be created anyways.", "Manage Link File", "4164 T10")

    if (result = "Yes")
    {
        FileMove A_ScriptDir . "\YT_URLS.txt", A_ScriptDir . "\YT_URLS_BACKUP.txt", 1
    }
    else if (result = "No")
    {

    }
    else if (result = "Timeout")
    {

    }
}

userStartDownload()
{
    if FileExist(A_ScriptDir . "\YT_URLS.txt")
    {
        openDownloadPage()
        static i := getCurrentURL(true)
        Loop i
        {
            if (startDownload(getCurrentURL(false)) = false)
            {
                result := MsgBox("Something went wrong !`n`nWould you like to continue ?", "Download error", "21 T3")

                if (result = "Retry")
                {
                    getCurrentURL_Success(true)
                    startDownload(getCurrentURL(false))
                }
                else if (result = "Cancel")
                {
                    ExitApp()
                }
                else if (result = "Timeout")
                {
                    MsgBox("Restart of the script is recommended !", "Warning !", "O Icon! T3")
                }
            }
        }
    }
    else
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
    try
    {
        manageURLFile()
    }
    Catch
    {
        MsgBox("The file does not exist !	`n`nIt was probably already cleared.", "Error", "O Icon! T3")
    }
}
Return

F2::
{
    try
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

    if (result = "Ok")
    {
        toggleDownloadFormat()
    }
    else if (result = "Cancel")
    {

    }
    else if (result = "Timeout")
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