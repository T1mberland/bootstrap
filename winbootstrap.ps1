# 設定ファイルダウンロード
Invoke-WebRequest `
  'https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/.wezterm.lua' `
  -OutFile "$HOME/Desktop/.wezterm.lua"

Invoke-WebRequest `
  'https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/keybindings.ahk' `
  -OutFile "$HOME/Desktop/keybindings.ahk"

# 必要なツールをインストール
$wingetPkgs = @(
  'Git.Git',
  'Neovim.Neovim',
  'Microsoft.PowerShell',
  'wez.wezterm',
  'BurntSushi.ripgrep.MSVC',
  'ajeetdsouza.zoxide',
  'sharkdp.fd',
  'AutoHotkey.AutoHotkey',
  'Vivaldi.Vivaldi'
)

foreach ($id in $wingetPkgs) {
    winget install --id $id -e --source winget `
        --accept-source-agreements --accept-package-agreements
}

# Git と Neovim のセットアップを「新しいウィンドウで」やる
$cloneAndRun = @'
if (!(Test-Path "$env:LOCALAPPDATA\nvim")) {
    git clone https://github.com/T1mberland/init.lua.git "$env:LOCALAPPDATA\nvim"
}
nvim
'@

Start-Process powershell.exe -ArgumentList '-NoExit','-Command', $cloneAndRun
