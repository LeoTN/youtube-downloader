#SingleInstance Force
SendMode "Input"
CoordMode "Mouse", "Client"
#Warn Unreachable, Off

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
activeHotkeyMenu.Add("Terminate Script -> " . readConfigFile(11),
    (*) => GUI_ToggleCheck("activeHotkeyMenu", "Terminate Script -> " . readConfigFile(11), 1), "+Radio")
activeHotkeyMenu.Add("Reload Script -> " . readConfigFile(12),
    (*) => GUI_ToggleCheck("activeHotkeyMenu", "Reload Script -> " . readConfigFile(12), 2), "+Radio")
activeHotkeyMenu.Add("Pause / Continue Script -> " . readConfigFile(13),
    (*) => GUI_ToggleCheck("activeHotkeyMenu", "Pause / Continue Script -> " . readConfigFile(13), 3), "+Radio")
activeHotkeyMenu.Add("Clear URL File -> " . readConfigFile(14),
    (*) => GUI_ToggleCheck("activeHotkeyMenu", "Clear URL File -> " . readConfigFile(14), 4), "+Radio")
activeHotkeyMenu.Add()
activeHotkeyMenu.Add("Enable All", (*) => GUI_MenuCheckAll("activeHotkeyMenu"))
activeHotkeyMenu.SetIcon("Enable All", "shell32.dll", 297)
activeHotkeyMenu.Add("Disable All", (*) => GUI_MenuUncheckAll("activeHotkeyMenu"))
activeHotkeyMenu.SetIcon("Disable All", "shell32.dll", 132)

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

mainGUI := Gui(, "YouTube Downloader Control Panel")
mainGUI.MenuBar := allMenus

/*
GUI SUPPORT FUNCTIONS
-------------------------------------------------
*/

; Necessary in place for the normal way of toggeling the checkmark.
; This function also flips the checkMarkArrays values to keep track of the checkmarks.
GUI_ToggleCheck(pMenuName, pMenuItemName, pMenuItemPosition)
{
    menuName := pMenuName
    menuItemName := pMenuItemName
    menuItemPosition := pMenuItemPosition

    ; Executes the command so that the checkmark becomes visible for the user.
    %menuName%.ToggleCheck(menuItemName)
    ; Registers the change in the matching array.
    GUI_MenuCheckHandler(menuName, menuItemPosition, "toggle")
}

GUI_MenuCheckAll(pMenuName)
{
    menuName := pMenuName
    menuItemCount := DllCall("GetMenuItemCount", "ptr", %menuName%.Handle)
    Loop (MenuItemCount - 2)
    {
        %menuName%.Check(A_Index . "&")
        ; Protects the code from the invalid index error caused by the check array further on.
        Try
        {
            GUI_MenuCheckHandler(menuName, A_Index, true)
        }
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
        ; Protects the code from the invalid index error caused by the check array further on.
        Try
        {
            GUI_MenuCheckHandler(menuName, A_Index, false)
        }
    }
    Return
}

; This function stores all menu items check states. In other words
; if there is a checkmark next to an option.
; The parameter menuName defines which menu's submenus will be changed.
; Enter "toggle" as pBooleanState to toggle a menu option's boolean value.
; Leave only booleanState ommited to receive the current value of a submenu item or
; every parameter to receive the complete array.
GUI_MenuCheckHandler(pMenuName := unset, pSubMenuPosition := unset, pBooleanState := unset)
{
    static menuCheckArray_activeHotKeyMenu := [0, 0, 0]
    Try
    {
        menuName := pMenuName
        subMenuPosition := pSubMenuPosition
    }
    Catch
    {
        Return menuCheckArray_activeHotKeyMenu
    }
    Try
    {
        booleanState := pBooleanState

        If (menuName = "activeHotkeyMenu")
        {
            If (booleanState = "toggle")
            {
                ; Toggles the boolean value at a specific position.
                menuCheckArray_activeHotKeyMenu[subMenuPosition] := !menuCheckArray_activeHotKeyMenu[subMenuPosition]
            }
            ; Only if there is a state given to apply to a menu.
            Else If (booleanState = true || booleanState = false)
            {
                menuCheckArray_activeHotKeyMenu[subMenuPosition] := booleanState
            }
            Else
            {
                Return menuCheckArray_activeHotKeyMenu[subMenuPosition]
            }
            toggleHotkey(menuCheckArray_activeHotKeyMenu)
        }
    }
    Return
}