#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

; Beginning of relevant getMethods.

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
        ; Makes finding a color more easy by accepting multiple variations.
        If (PixelSearch(&OutputX, &OutputY, MouseX, MouseY, MouseX, MouseX, color, variation) = true)
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
        currentURL_Array := readFile(readConfigFile("URL_FILE_LOCATION"), true)
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
; If the download fails, you have to call the getCurrentURL function again, but it would have deleted one link even
; though it was never downloaded.
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