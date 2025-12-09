# Bootstrap

## Windows

NerdFont: https://www.nerdfonts.com/

GoogleIME: https://www.google.co.jp/ime/

Win11Debloat : https://github.com/Raphire/Win11Debloat

OhMyZsh : https://ohmyz.sh/#install

- 以下のコマンドを PowerShell (v1.0) で実行

```powershell
& ([scriptblock]::Create((irm "https://t1mberland.github.io/bootstrap/win.ps1")))
```


- 以下をadmin権限でpowershellで実行

```powershell
wsl --install fedora
```

```bash
sudo dnf upgrade
sudo dnf install ncurses git neovim python3-neovim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/nvimbs.sh)"
```

- Zoxode

```
sudo dnf install zoxide
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
```


