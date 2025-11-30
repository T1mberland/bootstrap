# Bootstrap

## Windows

NerdFont: https://www.nerdfonts.com/

GoogleIME: https://www.google.co.jp/ime/

- Win11Debloat : https://github.com/Raphire/Win11Debloat

- 以下のコマンドを PowerShell (v1.0) で実行

```powershell
& ([scriptblock]::Create((irm "https://t1mberland.github.io/bootstrap/win.ps1")))
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

## Ubuntu

- Install Rust : https://rust-lang.org/tools/install/

```
cargo install ripgrep
```

```
cargo install zoxide --locked
```

```
cargo install --locked --features clipboard broot
```

```
cargo install --locked
```


## Fedora


