#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

global commandString := ""

createDownloadOptionsGUI()
{
    Global
    downloadOptionsGUI := Gui(, "Download Options")

    generalGroupbox := downloadOptionsGUI.Add("GroupBox", "w300 R3.2", "General Options")

    ignoreErrorsCheckbox := downloadOptionsGUI.Add("Checkbox", "xp+10 yp+20 Check3", "Ignore errors")
    abortOnErrorCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+20 Check3", "Abort on error")
    ignoreConfigFileCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+20", "Ignore config file")
    hideDownloadCommandPromptCheckbox := downloadOptionsGUI.Add("Checkbox", "xp+100 yp-40", "Download in a background task")
    askForDownloadConfirmationCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+20", "Ask for download confirmation")

    downloadGroupbox := downloadOptionsGUI.Add("GroupBox", "xp-110 yp+40 w394 R9.3", "Download Options")

    limitDownloadRateText1 := downloadOptionsGUI.Add("Text", "xp+10 yp+20", "Maximum download rate `n in MB per second.")
    limitDownloadRateEdit := downloadOptionsGUI.Add("Edit", "yp+30")
    limitDownloadRateUpDown := downloadOptionsGUI.Add("UpDown")
    limitDownloadRateText2 := downloadOptionsGUI.Add("Text", "yp+25", "Enter 0 for no limitations.")
    higherRetryAmountCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+20", "Increase retry amount")
    downloadVideoDescriptionCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+20 Checked", "Download the video description")
    downloadVideoCommentsCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+20", "Download the video's commentary section")
    downloadVideoThumbnail := downloadOptionsGUI.Add("Checkbox", "yp+20 Checked", "Download the video thumbnail")
    downloadVideoSubtitles := downloadOptionsGUI.Add("Checkbox", "yp+20", "Download the video's subtitles")

    chooseVideoFormatText := downloadOptionsGUI.Add("Text", "xp+250 yp-155", "Desired video format")
    downloadVideoFormatArray := ["mp4", "webm", "avi", "flv", "mkv", "mov"]
    chooseVideoFormatDropDownList := downloadOptionsGUI.Add("DropDownList", "y+17 Choose1", downloadVideoFormatArray)

    downloadAudioOnlyCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+30", "Download audio only")
    downloadAudioFormatArray := ["mp3", "wav", "m4a", "flac", "aac", "alac", "opus", "vorbis"]
    chooseAudioFormatDropDownList := downloadOptionsGUI.Add("DropDownList", "y+17 Choose1", downloadAudioFormatArray)

    fileSystemGroupbox := downloadOptionsGUI.Add("GroupBox", "xp-260 yp+85 w260 R5.2", "File Management")

    useTextFileForURLsCheckbox := downloadOptionsGUI.Add("Checkbox", "xp+10 yp+20 Checked", "Use collected URLs")
    customURLInputEdit := downloadOptionsGUI.Add("Edit", "yp+20 w240 Disabled", "Currently downloading collected URLs.")
    useDefaultDownloadLocationCheckbox := downloadOptionsGUI.Add("Checkbox", "yp+30 Checked", "Use default download path")
    customDownloadLocation := downloadOptionsGUI.Add("Edit", "yp+20 w240 Disabled", "Currently downloading into default directory.")

    ignoreErrorsCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    abortOnErrorCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    ignoreConfigFileCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    hideDownloadCommandPromptCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    askForDownloadConfirmationCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    higherRetryAmountCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    downloadVideoDescriptionCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    downloadVideoCommentsCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    downloadVideoThumbnail.OnEvent("Click", (*) => handleGUI_Checkboxes())
    downloadVideoSubtitles.OnEvent("Click", (*) => handleGUI_Checkboxes())
    useTextFileForURLsCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    useDefaultDownloadLocationCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())
    downloadAudioOnlyCheckbox.OnEvent("Click", (*) => handleGUI_Checkboxes())

    limitDownloadRateEdit.OnEvent("Change", (*) => handleGUI_InputFields())
    customURLInputEdit.OnEvent("Change", (*) => handleGUI_InputFields())
    chooseVideoFormatDropDownList.OnEvent("Change", (*) => handleGUI_InputFields())
    chooseAudioFormatDropDownList.OnEvent("Change", (*) => handleGUI_InputFields())
}

; Runs a few commands when the script is executed.
optionsGUI_onInit()
{
    createDownloadOptionsGUI()
    buildCommandString()
}

; Use embed options for later !!!

; GUI support function which enables and disables conflicting checkboxes.
GUI_enableDisableCheckboxes_GeneralOptions()
{
    If (ignoreErrorsCheckbox.Value = 1)
    {
        abortOnErrorCheckbox.Value := -1
        Return
    }
    If (abortOnErrorCheckbox.Value = 1)
    {
        ignoreErrorsCheckbox.Value := -1
        Return
    }
    If (ignoreErrorsCheckbox.Value = -1 && abortOnErrorCheckbox.Value = -1)
    {
        ignoreErrorsCheckbox.Value := 0
        abortOnErrorCheckbox.Value := 0
        Return
    }
}
; Function to react to changes made to any checkbox.
handleGUI_Checkboxes()
{
    global commandString
    GUI_enableDisableCheckboxes_GeneralOptions()

    Switch (ignoreErrorsCheckbox.Value)
    {
        Case 0:
        {
            ; Do not ignore most errors while downloading.
        }
        Case 1:
        {
            ; Do ignore most errors while downloading.
            commandString .= "--ignore-errors "
        }
    }
    Switch (abortOnErrorCheckbox.Value)
    {
        Case 0:
        {
            ; Do not abort on errors.
            commandString .= "--no-abort-on-error "
        }
        Case 1:
        {
            ; Do abort on errors.
            commandString .= "--abort-on-error "
        }
    }
    Switch (ignoreConfigFileCheckbox.Value)
    {
        Case 0:
        {
            ; Do not ignore the config file.
        }
        Case 1:
        {
            ; Do ignore the config file.
        }
    }
    Switch (hideDownloadCommandPromptCheckbox.Value)
    {
        Case 0:
        {
            ; Do not hide the download cmd.
        }
        Case 1:
        {
            ; Hide the download cmd.
        }
    }
    Switch (askForDownloadConfirmationCheckbox.Value)
    {
        Case 0:
        {
            ; Do not show a confirmation prompt before downloading.
        }
        Case 1:
        {
            ; Show a confirmation prompt before downloading.
        }
    }
    Switch (higherRetryAmountCheckbox.Value)
    {
        Case 0:
        {
            ; Do not increase maximum download retry amount of 10.
        }
        Case 1:
        {
            ; Increase the maximum download retry amount up to 30.
            commandString .= "--retries 30 "
        }
    }
    Switch (downloadVideoDescriptionCheckbox.Value)
    {
        Case 0:
        {
            ; Do not download the video description.
            commandString .= "--no-write-description "
        }
        Case 1:
        {
            ; Add the video description to a .description file.
            commandString .= "--write-description "
        }
    }
    Switch (downloadVideoCommentsCheckbox.Value)
    {
        Case 0:
        {
            ; Do not download the video's comment section.
            commandString .= "--no-write-comments "
        }
        Case 1:
        {
            ; Download the video 's comment section.
            commandString .= "--write-comments "
        }
    }
    Switch (downloadVideoThumbnail.Value)
    {
        Case 0:
        {
            ; Do not download the video thumbnail.
        }
        Case 1:
        {
            ; Download the video thumbnail and add it to the downloaded video.
            commandString .= "--write-thumbnail "
            commandString .= "--embed-thumbnail "
        }
    }
    Switch (downloadVideoSubtitles.Value)
    {
        Case 0:
        {
            ; Do not download the video's subtitles.
        }
        Case 1:
        {
            ; Download the video's subtitles and embed tem into the downloaded video.
            commandString .= "--write-description "
            commandString .= "--embed-subs "
        }
    }
    Switch (useTextFileForURLsCheckbox.Value)
    {
        Case 0:
        {
            ; Allow the user to download his own URL.
            customURLInputEdit.Opt("-Disabled")
            If (customURLInputEdit.Value = "Currently downloading collected URLs.")
            {
                customURLInputEdit.Value := "You can now enter your own URL."
            }
            commandString .= "--no-batch-file "
            commandString .= customURLInputEdit.Value . " "
        }
        Case 1:
        {
            ; Download selected URLs form the text file.
            customURLInputEdit.Opt("+Disabled")
            customURLInputEdit.Value := "Currently downloading collected URLs."
            ; Gives the .txt file with all youtube URLs to yt-dlp.
            commandString .= "--batch-file " . readConfigFile("URL_FILE_LOCATION") . " "
        }
    }
    Switch (useDefaultDownloadLocationCheckbox.Value)
    {
        Case 0:
        {
            ; Allows the user to select a custom download path.
            customDownloadLocation.Opt("-Disabled")
            ; Makes sure that a user input will not be overwritten.
            If (customDownloadLocation.Value = "Currently downloading into default directory.")
            {
                customDownloadLocation.Value := "You can now specify your own download path."
            }
            commandString .= "--paths " . customDownloadLocation.Value . " "
        }
        Case 1:
        {
            ; Keeps the default download directory.
            customDownloadLocation.Opt("+Disabled")
            customDownloadLocation.Value := "Currently downloading into default directory."
            commandString .= "--paths " . A_WorkingDir . "\files\download "
        }
    }
    Switch (downloadAudioOnlyCheckbox.Value)
    {
        Case 0:
        {
            ; Downloads the video with audi.
            chooseVideoFormatDropDownList.Opt("-Disabled")
            chooseAudioFormatDropDownList.Opt("+Disabled")
        }
        Case 1:
        {
            ; Only extracts the audio and creates the desired audio file type.
            chooseVideoFormatDropDownList.Opt("+Disabled")
            chooseAudioFormatDropDownList.Opt("-Disabled")
        }
    }
}
; Function that deals with changes made to any input field.
handleGUI_InputFields()
{
    global commandString
    If (limitDownloadRateEdit.Value != 0)
    {
        If (limitDownloadRateEdit.Value > 100)
        {
            limitDownloadRateEdit.Value := 100
        }
        ; Limit the download rate to a maximum value in Megabytes per second.
        commandString .= "--limit-rate " . limitDownloadRateEdit.Value . "MB "
    }
    If (downloadAudioOnlyCheckbox.Value = 0)
    {
        commandString .= ""
    }
}
; Support function for the download button. The parameter video amount
; can be used to only download a given number of videos before pausing again.
handleGUI_Button_startDownload(pVideoAmount := unset)
{
    If (IsSet(pVideoAmount))
    {
        videoAmount := pVideoAmount
    }
}
; This function parses through all values of the GUI and builds a command string
; which bill be given to the yt-dlp command prompt.
; Returns the string to it's caller.
buildCommandString()
{
    global commandString := "yt-dlp "
    handleGUI_Checkboxes()
    handleGUI_InputFields()
    ; Adds the ffmpeg location for the script to remux / extract audio etc.
    commandString .= "--ffmpeg-location " . A_WorkingDir . "\files\library\ffmpeg.exe "
    Return commandString
}
; Important function which executes the built command string by pasting it into the console.
executeCommandString(pCommandString, pBooleanSilent := false)
{
    stringToExecute := pCommandString
    booleanSilent := pBooleanSilent

    If (booleanSilent = true)
    {
        ; Execute the command line command and wait for it to be finished.
        RunWait(A_ComSpec " /c " . stringToExecute, , "Hide")
    }
    Else If (booleanSilent = false)
    {
        RunWait(A_ComSpec " /c " . stringToExecute)
    }

}