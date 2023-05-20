#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off
#Warn All, Off ;REMOVE !

;#Include "ConfigFileManager.ahk"
;#Include "HotKeys & Methods.ahk"

myGUI := Gui(, "YouTube Downloader Control Panel")

fileSelectionMenuOpen := Menu()
fileSelectionMenuOpen.Add("URL File`tF2", (*) => openURLFile())
fileSelectionMenuOpen.SetIcon("URL File`tF2", "shell32.dll", 104)
fileSelectionMenuOpen.Add("URL BackUp File`tShift+F2", (*) => openURLBackUpFile())
fileSelectionMenuOpen.SetIcon("URL BackUp File`tShift+F2", "shell32.dll", 46)
fileSelectionMenuOpen.Add("URL Blacklist File`tCTRL+F2", (*) => openURLBlacklistFile())
fileSelectionMenuOpen.SetIcon("URL Blacklist File`tCTRL+F2", "shell32.dll", 110)
fileSelectionMenuOpen.Add("Config File`tAlt+F2", (*) => openConfigFile())
fileSelectionMenuOpen.SetIcon("Config File`tAlt+F2", "shell32.dll", 70)

fileSelectionMenuDelete := Menu()
fileSelectionMenuDelete.Add("URL File", (*) => openURLFile())
fileSelectionMenuDelete.SetIcon("URL File", "shell32.dll", 104)
fileSelectionMenuDelete.Add("URL BackUp File", (*) => openURLBackUpFile())
fileSelectionMenuDelete.SetIcon("URL BackUp File", "shell32.dll", 46)
fileSelectionMenuDelete.Add("URL Blacklist File", (*) => openURLBlacklistFile())
fileSelectionMenuDelete.SetIcon("URL Blacklist File", "shell32.dll", 110)
fileSelectionMenuDelete.Add("Config File", (*) => openConfigFile())
fileSelectionMenuDelete.SetIcon("Config File", "shell32.dll", 70)

fileMenu := Menu()
fileMenu.Add("&Open...", fileSelectionMenuOpen)
fileMenu.Add("&Delete...", fileSelectionMenuDelete)

helpMenu := Menu()
helpMenu.Add "Info", (*) => MsgBox("Nicht implementiert")
allMenus := MenuBar()
allMenus.Add "&File", fileMenu  ; Fügt die zwei oben erstellten Untermenüs hinzu.
allMenus.Add "&?", helpMenu
myGUI := Gui()
myGUI.MenuBar := allMenus
myGUI.Show "w300 h200"