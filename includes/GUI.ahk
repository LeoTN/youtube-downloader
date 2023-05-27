#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off
#Warn All, Off ;REMOVE !

; WARNING ! GUI IN TEST PHASE
#Include "ConfigFileManager.ahk"
#Include "HotKeys & Methods.ahk"

fileSelectionMenuOpen := Menu()
fileSelectionMenuOpen.Add("URL-File`tF2", (*) => openURLFile())
fileSelectionMenuOpen.SetIcon("URL-File`tF2", "shell32.dll", 104)
fileSelectionMenuOpen.Add("URL-BackUp-File`tShift+F2", (*) => openURLBackUpFile())
fileSelectionMenuOpen.SetIcon("URL-BackUp-File`tShift+F2", "shell32.dll", 46)
fileSelectionMenuOpen.Add("URL-Blacklist-File`tCTRL+F2", (*) => openURLBlacklistFile())
fileSelectionMenuOpen.SetIcon("URL-Blacklist-File`tCTRL+F2", "shell32.dll", 110)
fileSelectionMenuOpen.Add("Config-File`tAlt+F2", (*) => openConfigFile())
fileSelectionMenuOpen.SetIcon("Config-File`tAlt+F2", "shell32.dll", 70)

fileSelectionMenuDelete := Menu()
fileSelectionMenuDelete.Add("URL-File", (*) => deleteFilePrompt("URL-File"))
fileSelectionMenuDelete.SetIcon("URL-File", "shell32.dll", 104)
fileSelectionMenuDelete.Add("URL-BackUp-File", (*) => deleteFilePrompt("URL-BackUp-File"))
fileSelectionMenuDelete.SetIcon("URL-BackUp-File", "shell32.dll", 46)
fileSelectionMenuDelete.Add("URL-Blacklist-File", (*) => deleteFilePrompt("URL-Blacklist-File"))
fileSelectionMenuDelete.SetIcon("URL-Blacklist-File", "shell32.dll", 110)
fileSelectionMenuDelete.Add("Downloaded Videos", (*) => deleteFilePrompt("Downloaded Videos"))
fileSelectionMenuDelete.SetIcon("Downloaded Videos", "shell32.dll", 116)

fileSelectionMenuReset := Menu()
fileSelectionMenuReset.Add("URL-File", (*) => clearURLFile())
fileSelectionMenuReset.SetIcon("URL-File", "shell32.dll", 104)
fileSelectionMenuReset.Add("URL-BackUp-File", (*) => MsgBox("Not implemented"))
fileSelectionMenuReset.SetIcon("URL-BackUp-File", "shell32.dll", 46)
fileSelectionMenuReset.Add("URL-Blacklist-File", (*) => MsgBox("Not implemented"))
fileSelectionMenuReset.SetIcon("URL-Blacklist-File", "shell32.dll", 110)
fileSelectionMenuReset.Add("Config-File", (*) => createDefaultConfigFile())
fileSelectionMenuReset.SetIcon("Config-File", "shell32.dll", 70)

fileMenu := Menu()
fileMenu.Add("&Open...", fileSelectionMenuOpen)
fileMenu.SetIcon("&Open...", "shell32.dll", 127)
fileMenu.Add("&Delete...", fileSelectionMenuDelete)
fileMenu.SetIcon("&Delete...", "shell32.dll", 32)
fileMenu.Add("&Reset...", fileSelectionMenuReset)
fileMenu.SetIcon("&Reset...", "shell32.dll", 239)


optionsMenu := Menu()
optionsMenu.Add("&Future Option...", (*) => MsgBox("Add future option"))

helpMenu := Menu()
; Add help doc in the future.
helpMenu.Add("&Info", (*) => MsgBox("Add help here"))

allMenus := MenuBar()
allMenus.Add("&File", fileMenu)
allMenus.Add("&Options", optionsMenu)
allMenus.Add("&?", helpMenu)

myGUI := Gui(, "YouTube Downloader Control Panel")
myGUI.MenuBar := allMenus