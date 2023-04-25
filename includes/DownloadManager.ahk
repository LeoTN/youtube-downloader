#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

#Include "GlobalVariables.ahk"

; Beginning of the download related functions.

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
; Currently not used.
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