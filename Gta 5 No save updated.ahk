#Requires AutoHotkey v2.0

; --- AUTOMATIC ADMIN ELEVATION ---
if not A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; Universal key stroke delays for main menus
SetKeyDelay(50, 50) 

global stepState := 0

; =========================================================================
; MANUAL ON/OFF HOTKEYS
; =========================================================================

*Numpad2:: {
    saveblockEnable()
}
*NumpadDown:: { 
    saveblockEnable()
}

*Numpad3:: {
    saveblockDisable()
}
*NumpadPgDn:: { 
    saveblockDisable()
}

; =========================================================================
; AUTOMATION LOOP ENGINE
; =========================================================================

*Numpad1:: {
    StartMacro()
}
*NumpadEnd:: {
    StartMacro()
}

StartMacro() {
    global stepState
    if (stepState == 0) {
        SoundBeep(400, 150)
        stepState := 1
        RunMacroLoop()
    }
}

RunMacroLoop() {
    global stepState
    
    ; --- STEP 1: Online to Story Mode ---
    if (stepState == 1) {
        TextFeedback("[Macro State] Running Step 1: Navigating Menu to Story Mode", true)
        SendEvent("p") 
        Sleep(600)
        
        SendEvent("{Right}") 
        Sleep(600)      
        SendEvent("{Enter}")
        Sleep(1000)     
        
        ; VERTICAL UP INPUT SEQUENCE
        SendEvent("{Up}")
        Sleep(150)       
        SendEvent("{Up}")
        Sleep(30)
        SendEvent("{Up}")
        Sleep(200)
        
        SendEvent("{Enter}")
        Sleep(400)
        SendEvent("{Enter}")   
        
        TextFeedback("[Macro State] In Clouds: Waiting 20 Seconds For Story Mode...", true)
        Sleep(20000) 
        
        stepState := 2
        RunMacroLoop()
    }
    
    ; --- STEP 2: Firewall Cycle & Initial Online Loading Setup ---
    else if (stepState == 2) {
        TextFeedback("[Macro State] Landed in Story Mode: Resetting Firewall Protection", true)
        Sleep(2000)
        saveblockDisable() 
        Sleep(2000)
        
        stepState := 3
        LoadClosedFriendSession() 
    }
    
    ; --- STEP 4: First Online Spawn Detected -> Process Outfit / Appearance Menu ---
    else if (stepState == 4) {
        TextFeedback("[Macro State] Spawned Online: Opening Interaction Menu", true)
        SendEvent("m") 
        Sleep(400) 
        
        TextFeedback("[Macro State] Rapid Scrolling Up to Appearance Parameters", true)
        SendEvent("{Up}")
        Sleep(40)
        SendEvent("{Up}")
        Sleep(40)
        SendEvent("{Up}")
        Sleep(40)
        SendEvent("{Up}")
        Sleep(40)
        SendEvent("{Up}")
        Sleep(40)
        SendEvent("{Up}")
        Sleep(100)
        
        SendEvent("{Enter}")
        Sleep(150)
        
        TextFeedback("[Macro State] Rapid Outfit Selection", true)
        SendEvent("{Down}")
        Sleep(40)
        SendEvent("{Down}")
        Sleep(40)
        SendEvent("{Down}")
        Sleep(100)
        
        SendEvent("{Right}") 
        Sleep(100)
        SendEvent("{Enter}")
        Sleep(150)
        
        SendEvent("m") 
        TextFeedback("[Macro State] Outfits Changed. Waiting 8 Seconds for Cloud Sync", true)
        Sleep(8000)    
        
        stepState := 5
        ; --- STEP 5: Online to Story Mode (Second Time) ---
        TextFeedback("[Macro State] Running Step 5: Returning to Story Mode", true)
        SendEvent("p") 
        Sleep(600)
        
        SendEvent("{Right}") 
        Sleep(600)      
        SendEvent("{Enter}")
        Sleep(1000)     
        
        ; VERTICAL UP INPUT SEQUENCE
        SendEvent("{Up}")
        Sleep(150)       
        SendEvent("{Up}")
        Sleep(30)
        SendEvent("{Up}")
        Sleep(200)
        
        SendEvent("{Enter}")
        Sleep(400)
        SendEvent("{Enter}")
        
        TextFeedback("[Macro State] In Clouds: Waiting 20 Seconds For Story Mode (Cycle 2)...", true)
        Sleep(20000) 
        
        stepState := 6
        RunMacroLoop()
    }
    
    ; --- STEP 7: Final Online Session Load ---
    else if (stepState == 6) {
        LoadClosedFriendSession()
    }
}

LoadClosedFriendSession() {
    global stepState
    
    TextFeedback("[Macro State] Force Opening Pause Menu via P Key...", true)
    SendEvent("p")
    Sleep(1500) 
    
    TextFeedback("[Macro State] Navigating Menu to Launch Closed Friend Session", true)
    
    ; FIXED TABS TRAJECTORY: Kept 1st Right arrow press at 300ms, sped the rest up to 40ms
    SendEvent("{Right}")
    Sleep(300)
    SendEvent("{Right}")
    Sleep(40)
    SendEvent("{Right}")
    Sleep(40)
    SendEvent("{Right}")
    Sleep(40)
    SendEvent("{Right}")
    Sleep(600)      
    
    SendEvent("{Enter}")
    Sleep(550)
    SendEvent("{Up}") 
    Sleep(550)
    SendEvent("{Enter}")
    Sleep(550)
    
    SendEvent("{Up}") 
    Sleep(550)   
    SendEvent("{Enter}")
    Sleep(550)
    
    SendEvent("{Enter}") 
    
    if (stepState == 3) {
        TextFeedback("[Macro State] In Clouds: Verifying Stable Online HUD Spawn...", true)
        WaitForOnlineModeLoad() 
    } else {
        stepState := 0 
        SoundPlay("*-1") 
        ToolTip("GTA 5 Macro Cycle Complete! Final Session Loaded.", 10, 10)
        SetTimer(() => ToolTip(), -25000) 
    }
}

; =========================================================================
; REINFORCED ONLINE PIXEL DETECTION ENGINE
; =========================================================================

WaitForOnlineModeLoad() {
    confirmCount := 0
    
    Loop {
        Sleep(250) 
        CoordMode("Pixel", "Window")
        try {
            if PixelSearch(&pX, &pY, 20, 800, 420, 1060, 0xFFFFFF, 8) {
                confirmCount++
                if (confirmCount >= 12) {
                    break
                }
            } else {
                confirmCount := 0
            }
        } catch {
            confirmCount := 0
            continue
        }
    }
    
    Sleep(7000) 
    
    global stepState
    if (stepState == 3) {
        stepState := 4 
        RunMacroLoop()
    }
}

; =========================================================================
; FIREWALL ENGINE FUNCTIONS
; =========================================================================

saveblockEnable() {
    RunWait('netsh advfirewall firewall add rule name="GTAOSAVEBLOCK" dir=out action=block remoteip="192.81.241.171"', , "hide")
    TextFeedback("NO SAVING MODE ON", true) 
}

saveblockDisable() {
    RunWait('netsh advfirewall firewall delete rule name="GTAOSAVEBLOCK"', , "hide")
    TextFeedback("NO SAVING MODE OFF", false) 
}

TextFeedback(message, persistent := false) {
    ToolTip(message, 10, 10)
    if (!persistent) {
        SetTimer(() => ToolTip(), -3000) 
    }
}
