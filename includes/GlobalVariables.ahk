#SingleInstance Force
SendMode "Input"
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