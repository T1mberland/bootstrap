# Bootstrap

## Windows

NerdFont: https://www.nerdfonts.com/

GoogleIME: https://www.google.co.jp/ime/

AutoHotKey: https://github.com/AutoHotkey/AutoHotkey/releases

SumatraPDF: https://www.sumatrapdfreader.org/downloadafter

- 以下のコマンドを PowerShell (v1.0) で実行

```powershell
$(curl https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/.wezterm.lua).Content > ~/.wezterm.lua
$(curl https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/keybindings.ahk).Content > ~/keybindings.ahk
winget install Microsoft.PowerShell
winget install wez.wezterm
winget install --id Git.Git -e --source winget
winget install BurntSushi.ripgrep.MSVC
winget install flxzt.rnote
```

- 以下をadmin権限でpowershellで実行

```powershell
wsl --install
```


- install zsh

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y zsh
chsh -s "$(which zsh)"
```
