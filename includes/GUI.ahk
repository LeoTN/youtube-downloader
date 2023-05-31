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
fileSelectionMenuReset.Add("URL-Blacklist-File", (*) => openURLBlacklistFile(true))
fileSelectionMenuReset.SetIcon("URL-Blacklist-File", "shell32.dll", 110)
fileSelectionMenuReset.Add("Config-File", (*) => createDefaultConfigFile(, true))
fileSelectionMenuReset.SetIcon("Config-File", "shell32.dll", 70)

fileMenu := Menu()
fileMenu.Add("&Open...", fileSelectionMenuOpen)
fileMenu.SetIcon("&Open...", "shell32.dll", 127)
fileMenu.Add("&Delete...", fileSelectionMenuDelete)
fileMenu.SetIcon("&Delete...", "shell32.dll", 32)
fileMenu.Add("&Reset...", fileSelectionMenuReset)
fileMenu.SetIcon("&Reset...", "shell32.dll", 239)

activeHotkeyMenu := Menu()
; Still incomplete.
activeHotkeyMenu.Add("Terminate Script -> " . "add_hotkey_here",
    (*) => activeHotkeyMenu.ToggleCheck("Terminate Script -> " . "add_hotkey_here"), "+Radio")
activeHotkeyMenu.Add("Reload Script -> " . "add_hotkey_here",
    (*) => activeHotkeyMenu.ToggleCheck("Reload Script -> " . "add_hotkey_here"), "+Radio")
activeHotkeyMenu.Add("Clear URL File -> " . "add_hotkey_here",
    (*) => activeHotkeyMenu.ToggleCheck("Clear URL File -> " . "add_hotkey_here"), "+Radio")
activeHotkeyMenu.Add()
activeHotkeyMenu.Add("Enable All", (*) => GUI_MenuCheckAll("activeHotkeyMenu"))
activeHotkeyMenu.SetIcon("Enable All", "shell32.dll", 297)
activeHotkeyMenu.Add("Disable All", (*) => GUI_MenuUncheckAll("activeHotkeyMenu"))
activeHotkeyMenu.SetIcon("Disable All", "shell32.dll", 132)
activeHotkeyMenu.Add("Test", (*) => test())


optionsMenu := Menu()
optionsMenu.Add("&Active Hotkeys...", activeHotkeyMenu)
optionsMenu.SetIcon("&Active Hotkeys...", "shell32.dll", 177)
optionsMenu.Add()
optionsMenu.Add("Terminate Script", (*) => terminateScriptPrompt())
optionsMenu.SetIcon("Terminate Script", "shell32.dll", 28)
optionsMenu.Add("Reload Script", (*) => reloadScriptPrompt())
optionsMenu.SetIcon("Reload Script", "shell32.dll", 207)

helpMenu := Menu()
; Add help doc in the future.
helpMenu.Add("&Info", (*) => MsgBox("Add help here"))

allMenus := MenuBar()
allMenus.Add("&File", fileMenu)
allMenus.SetIcon("&File", "shell32.dll", 4)
allMenus.Add("&Options", optionsMenu)
allMenus.SetIcon("&Options", "shell32.dll", 317)
allMenus.Add("Info", helpMenu)
allMenus.SetIcon("Info", "shell32.dll", 24)

myGUI := Gui(, "YouTube Downloader Control Panel")
myGUI.MenuBar := allMenus

/*
GUI SUPPORT FUNCTIONS
-------------------------------------------------
*/

GUI_MenuCheckAll(pMenuName)
{
    menuName := pMenuName
    menuItemCount := DllCall("GetMenuItemCount", "ptr", %menuName%.Handle)
    Loop (MenuItemCount - 2)
    {
        %menuName%.Check(A_Index . "&")
    }
    Return
}

GUI_MenuUncheckAll(pMenuName)
{
    menuName := pMenuName
    menuItemCount := DllCall("GetMenuItemCount", "ptr", %menuName%.Handle)
    Loop (MenuItemCount - 2)
    {
        %menuName%.Uncheck(A_Index . "&")
    }
    Return
}

test()
{
    isChecked := DllCall("GetMenuItemInfoA", "ptr", activeHotkeyMenu.Handle, "6&")
    MsgBox(isChecked)
}