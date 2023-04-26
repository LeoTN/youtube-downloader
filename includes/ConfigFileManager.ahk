#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

; Makes sure every function can open the firefox download instance. Receives an actual string in openDownloadPage().
global firefoxWindow := ""

/*
DEBUG SECTION
-------------------------------------------------
Add debug variables here.
*/
; This variable is also written into the config file.
booleanDebugMode := false

;------------------------------------------------

/*
CONFIG VARIABLE TEMPLATE SECTION
-------------------------------------------------
These default variables are used to generate the config file template.
***IMPORTANT NOTE*** : Do NOT change the order of these variables !
Otherwise this can lead to fatal erros and failures !
*/

; Determines the location of the script's configuration file.
global configFileLocation := A_WorkingDir . "\files\ytdownloader.ini"
; Specifies path for the .txt file which stores the URLs.
URL_FILE_LOCATION := A_ScriptDir . "\files\YT_URLS.txt"
; Specifies path for the .txt file which stores the URL backup.
URL_BACKUP_FILE_LOCATION := A_ScriptDir . "\files\YT_URLS_BACKUP.txt"
; Specifies path for the .txt file which stores the blacklist file.
BLACKLIST_FILE_LOCATION := A_ScriptDir . "\files\YT_BLACKLIST.txt"

;------------------------------------------------

; Will contain all config values matching with each variable name in the array below.
; For example configVariableNameArray[2] = "URL_FILE_LOCATION"
; and configFileContentArray[2] = "A_ScriptDir . "\files\YT_URLS.txt""
; so basically URL_FILE_LOCATION = "A_ScriptDir . "\files\YT_URLS.txt"".
; NOTE : This had to be done because changing a global variable using a dynamic
; expression like global %myGlobalVarName% := "newValue" won't work.
global configFileContentArray := []

; Create an array including all settings variables names.
; This array makes it easier to apply certain values from the config file to the configFileContentArray.
; IMPORTANT NOTE : Do NOT forget to add each new config variable name into the array !!!
configVariableNameArray := [
    "booleanDebugMode",
    "URL_FILE_LOCATION",
    "URL_BACKUP_FILE_LOCATION",
    "BLACKLIST_FILE_LOCATION"
]
; Create an array including the matching section name for EACH item in the configVariableNameArray.
; This makes it easier to read and write the config file.
; IMPORTANT NOTE : Do NOT forget to add the SECTION NAME for EACH new item added in the configVariableNameArray !!!
configSectionNameArray := [
    "DebugSettings",
    "FileLocations",
    "FileLocations",
    "FileLocations"
]

/*
CONFIG FILE SECTION
-------------------------------------------------
Creates, reads and manages the script's config file.
*/

createDefaultConfigFile(pBooleanCreateBackUp := true)
{
    booleanCreateBackUp := pBooleanCreateBackUp
    If (booleanCreateBackUp = true)
    {
        If (FileExist(configFileLocation))
        {
            FileMove(configFileLocation, configFileLocation . "_old", true)
        }
        If (!DirExist(A_WorkingDir . "\files"))
        {
            DirCreate(A_WorkingDir . "\files")
        }
        FileAppend("", configFileLocation)
    }
    ; In case you forget to specify a section for EACH new config file entry this will remind you to do so :D
    If (configVariableNameArray.Length != configSectionNameArray.Length)
    {
        MsgBox("Not every config file entry has been asigned to a section !`n`nPlease fix this by checking both arrays.", "Error", "O IconX")
        MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
        ExitApp()
    }
    Else
    {
        /*
        This it what it looked like before using an array to define all parameters.
        IniWrite(URL_FILE_LOCATION, configFileLocation, "FileLocations", "URL_FILE_LOCATION")
        */
        Loop configVariableNameArray.Length
        {
            IniWrite(%configVariableNameArray[A_Index]%, configFileLocation, configSectionNameArray[A_Index], configVariableNameArray[A_Index])
        }
    }
    Return
}

; Reads the config file and extracts it's values.
; The parameter variableNameArrayIndex specifies a specific
; variable's content which you want to return.
; For example (2) to return URL_FILE_LOCATION's content
; which is 'A_ScriptDir . "\files\YT_URLS.txt"' by default.
; Leave this parameter ommited to receive the complete array.
; Returns an array with the content of the config file.
readConfigFile(pVariableNameArrayIndex := 0)
{
    variableNameArrayIndex := pVariableNameArrayIndex
    ; Writes the settings into the configFileArray.
    Loop configVariableNameArray.Length
    {
        Try
        {
            ; Replaces every config variable 's value with the config file's content.
            configFileContentArray.InsertAt(A_Index, IniRead(configFileLocation, configSectionNameArray[A_Index]
            , configVariableNameArray[A_Index]))
        }
        Catch
        {
            result := MsgBox("The script's config file seems to be corrupted or unavailable !`n`nDo you want to create a new one using the template ?"
                , "Error", "YN IconX 8192 T10")
            If (result = "Yes")
            {
                createDefaultConfigFile()
                readConfigFile(variableNameArrayIndex)
                Return
            }
            Else If (result = "No")
            {
                MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                ExitApp()
            }
            Else If (result = "Timeout")
            {
                MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                ExitApp()
            }
        }
    }
    If (variableNameArrayIndex = 0)
    {
        Return configFileContentArray
    }
    Else
    {
        ; The following code only applies for path values.
        ; Everything else should be excluded.
        If (InStr(configFileContentArray[variableNameArrayIndex], "\"))
        {
            ; If necessary the directory read in the config file will be created.
            ; SplitPath makes sure the last part of the whole path is removed.
            ; For example it removes the "\YT_URLS.txt"
            SplitPath(configFileContentArray[variableNameArrayIndex], , &outDir)
            ; Looks for one of the specified characters to identify invalid path names.
            ; Searches for common mistakes in the path name.
            specialChars := '<>"/|?*'
            Loop Parse, specialChars
            {
                If (InStr(outDir, A_LoopField))
                {
                    MsgBox("Could not create directory !`nCheck the config file for a valid path at : `n " . configVariableNameArray[variableNameArrayIndex], "Error", "O Icon! T10")
                    MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                    ExitApp()
                }
                If (InStr(outDir, "\\"))
                {
                    MsgBox("Could not create directory !`nCheck the config file for a valid path at : `n " . configVariableNameArray[variableNameArrayIndex], "Error", "O Icon! T10")
                    MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                    ExitApp()
                }
                If (InStr(outDir, "\\\"))
                {
                    MsgBox("Could not create directory !`nCheck the config file for a valid path at : `n " . configVariableNameArray[variableNameArrayIndex], "Error", "O Icon! T10")
                    MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                    ExitApp()
                }
            }
            If (!DirExist(outDir))
            {
                result := MsgBox("The directory :`n" . configFileContentArray[variableNameArrayIndex] . "`ndoes not exist. `nWould you like to create it ?", "Warning !", "YN Icon! T10")
                If (result = "Yes")
                {
                    Try
                    {
                        DirCreate(outDir)
                        Return configFileContentArray[variableNameArrayIndex]
                    }
                    Catch
                    {
                        MsgBox("Could not create directory !`nCheck the config file for an valid path at : `n " . configVariableNameArray[variableNameArrayIndex], "Error", "O Icon! T3")
                        MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                        ExitApp()
                    }
                }
                Else If (result = "No")
                {
                    MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                    ExitApp()
                    ExitApp()
                }
                Else If (result = "Timeout")
                {
                    MsgBox("Script has been terminated.", "Script status", "O IconX T1.5")
                    ExitApp()
                    ExitApp()
                }
            }
        }
    }
    Return configFileContentArray[variableNameArrayIndex]
}

; The parameter variableNameArrayIndex specifies a specific
; variable's content which you want to edit.
; The parameter data holds the new data for the config file.
editConfigFile(pVariableNameArrayIndex, pData)
{
    variableNameArrayIndex := pVariableNameArrayIndex
    data := pData
    ; Basically the same as creating the config file but not with a loop.
    IniWrite(data, configFileLocation
        , configSectionNameArray[variableNameArrayIndex]
        , configVariableNameArray[variableNameArrayIndex])
}

/*
NOT USED

; The parameter value means the data you want to edit.
; For example a string or a number.
; The parameter section is the part in the config file
; where the keyName can be found.
; The parameter keyName is the name of the item
; which you want to edit it's data.
editConfigFile(pValue, pSection, pKeyName)
{
    value := pValue
    section := pSection
    keyName := pKeyName

    IniWrite(value, configFileLocation, section, keyName)
    Return
}

*/
