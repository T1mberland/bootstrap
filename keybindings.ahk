!1::  ; Alt+1 -> terminal(wezterm)
{
    if WinExist("ahk_class org.wezfurlong.wezterm")
        WinActivate
    else
        Run A_ProgramFiles "\WezTerm\wezterm-gui.exe" ; Wezterm : "C:\\Program Files\\WezTerm\\wezterm-gui.exe"
        ;Run A_ProgramFiles "\WezTerm\wezterm-gui.exe" 
}

!2::
{
    if WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")
        WinActivate
    else
        Run A_ProgramFiles "\PowerShell\7\pwsh.exe" ; Wezterm : "C:\\Program Files\\WezTerm\\wezterm-gui.exe"
}

!9:: { ; Alt+9
    if WinExist("ahk_exe Obsidian.exe")
        WinActivate
    else
        Run EnvGet("LOCALAPPDATA") "\Programs\Obsidian\Obsidian.exe"
}

!0::  ; Alt+0
{
    if WinExist("ahk_exe vivaldi.exe")
        WinActivate
    else
        Run EnvGet("LOCALAPPDATA") "\Vivaldi\Application\vivaldi.exe"
}

; 「￥（バックスラッシュ）」キー ==> バックスペース
sc7D::Send "{BS}"
; 「ろ」キー は バックスペース
sc73::Send "\"

; 無変換 + H/J/K/L で矢印キー
sc07B & h::Send "{Left}"
sc07B & j::Send "{Down}"
sc07B & k::Send "{Up}"
sc07B & l::Send "{Right}"

; 変換->backspace
;sc079::Send "{BS}"

; 変換->Ctrl
sc079::LCtrl

; 無変換+(U/I/O/P) -> backspace
;sc07B & u::Send "{BS}"
;sc07B & i::Send "{BS}"
;sc07B & o::Send "{BS}"
;sc07B & p::Send "{BS}"

; 変換+(J/K/L/U/I/O/P) -> backspace
;sc079 & j::Send "{BS}"
;sc079 & k::Send "{BS}"
;sc079 & l::Send "{BS}"

;sc079 & u::Send "{BS}"
;sc079 & i::Send "{BS}"
;sc079 & o::Send "{BS}"
;sc079 & p::Send "{BS}"

; ALT + H/J/K/L で矢印キー
;!h::Send "{Left}"
;!j::Send "{Down}"
;!k::Send "{Up}"
;!l::Send "{Right}"

;-----------------------------------------------------------
; IMEの状態の取得
;   WinTitle="A"    対象Window
;   戻り値          1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle:="A")  {
    hwnd := WinExist(WinTitle)
    if  (WinActive(WinTitle))   {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        cbSize := 4+4+(PtrSize*6)+16
        stGTI := Buffer(cbSize,0)
        NumPut("DWORD", cbSize, stGTI.Ptr,0)   ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", "Uint",0, "Uint", stGTI.Ptr)
                 ? NumGet(stGTI.Ptr,8+PtrSize,"Uint") : hwnd
    }
    return DllCall("SendMessage"
          , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",hwnd)
          , "UInt", 0x0283  ;Message : WM_IME_CONTROL
          ,  "Int", 0x0005  ;wParam  : IMC_GETOPENSTATUS
          ,  "Int", 0)      ;lParam  : 0
}

IME_Set(state, hwnd := WinExist("A")) {
    if WinActive("A") {
        cbSize := 4 + 4 + (A_PtrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI)
            hwnd := NumGet(stGTI, 8 + A_PtrSize, "Ptr")
    }
    hIME := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    return DllCall("SendMessage", "Ptr", hIME
        , "UInt", 0x0283   ; WM_IME_CONTROL
        , "Ptr",  0x0006   ; IMC_SETOPENSTATUS
        , "Ptr",  state ? 1 : 0)
}

; CapsLock->Ctrl
;CapsLock::Send "{Ctrl}"

; CAPSLOCK でIMEトグル
CapsLock::
{
    s := IME_Get()
    IME_Set(!s)
}

; 変換でIMEトグル
;sc079::
;{
    ;s := IME_Get()
    ;IME_Set(!s)
;}

;CapsLock::Send "{F24}"

; 変換 -> IME ON
;sc079::
;{
    ;IME_Set(1)
;}

; 無変換 -> IME OFF
;sc07B::
;{
    ;IME_Set(0)
;}

; Shift+無変換 -> BS?
; Shift+変換 -> BS?
; Shift+カタカナひらがなローマ字 -> BS?
;+sc07B::Send "{BS}"
;+sc079::Send "{BS}"
;+sc070::Send "{BS}"

