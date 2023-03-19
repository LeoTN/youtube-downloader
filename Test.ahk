#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

controlPanel := Gui()
controlPanel.BackColor := "White"
controlPanel.Add("Picture", "x0 y0 h350 w450", A_ScriptDir "/yt_1200.png")
confirmButton := controlPanel.Add("Button", "Default xp+20 yp+250", "Save Changes")
confirmButton.OnEvent("Click", AnimiereLeiste) ;Später userStarteDownload()
MeinProgress := controlPanel.Add("Progress", "w416")
MeinText := controlPanel.Add("Text", "wp")  ; wp bedeutet "vorherige Breite verwenden".
controlPanel.Show()

AnimiereLeiste(*)
{
    Loop Files, A_WinDir "\*.*"
    {
        if (A_Index > 100)
            break
        MeinProgress.Value := A_Index
        MeinText.Value := A_LoopFileName
        Sleep 50
    }
    MeinText.Value := "Animation beendet."
}