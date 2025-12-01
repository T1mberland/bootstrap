$wingetAllPkgs = @(
  [pscustomobject]@{ Name = 'Neovim.Neovim'; Enabled = $true }
  [pscustomobject]@{ Name = 'Git.Git'; Enabled = $true }
  [pscustomobject]@{ Name = 'Microsoft.PowerShell'; Enabled = $true }
  [pscustomobject]@{ Name = 'wez.wezterm'; Enabled = $true }
  [pscustomobject]@{ Name = 'BurntSushi.ripgrep.MSVC'; Enabled = $true }
  [pscustomobject]@{ Name = 'ajeetdsouza.zoxide'; Enabled = $true }
  [pscustomobject]@{ Name = 'sharkdp.fd'; Enabled = $true }
  [pscustomobject]@{ Name = 'eza-community.eza'; Enabled = $true }
  [pscustomobject]@{ Name = 'AutoHotkey.AutoHotkey'; Enabled = $true }
  [pscustomobject]@{ Name = 'SumatraPDF.SumatraPDF'; Enabled = $true }
  [pscustomobject]@{ Name = 'flxzt.rnote'; Enabled = $false }
  [pscustomobject]@{ Name = 'Microsoft.VisualStudioCode'; Enabled = $false }
  [pscustomobject]@{ Name = 'Vivaldi.Vivaldi'; Enabled = $false }
)

$configAll = @(
  [pscustomobject]@{ Name = 'Neovim (~/AppData/Local/nvim/init.lua)'; Enabled = $false }
  [pscustomobject]@{ Name = 'AutoHotKey (~/Desktop/keybindings.ahk)'; Enabled = $false }
  [pscustomobject]@{ Name = 'Wezterm (~/.wezterm.lua)'; Enabled = $false }
)

function Show-Menu {
  param([Parameter(Mandatory)][object[]]$Items)

  $index = 0
  $esc = [char]27

  :MenuLoop while ($true) {
    Clear-Host
    Write-Host "Use $esc[4mjk$esc[0m to move, $esc[4mSpace$esc[0m to toggle, $esc[4ma$esc[0m to select/deselect all."
    Write-Host "$esc[4mEnter$esc[0m to confirm, $esc[4mq$esc[0m to quit.`n"

    for ($i = 0; $i -lt $Items.Count; $i++) {
      $prefix = if ($i -eq $index) { '>' } else { ' ' }
      $check = if ($Items[$i].Enabled) { '[x]' } else { '[ ]' }
      Write-Host "$prefix $check $($Items[$i].Name)"
    }

    $key = [System.Console]::ReadKey($true)

    if ($key.Key -in 'q', 'Q') {
      exit 0
    }
    elseif ($key.Key -in 'a', 'A') {
      $allOn = $Items.Enabled -notcontains $false
      $newVal = -not $allOn
      for ($i = 0; $i -lt $Items.Count; $i++) {
        $Items[$i].Enabled = $newVal
      }
      continue
    }
    elseif ($key.Key -in 'j', 'J', 'DownArrow') {
      if ($index -lt $Items.Count - 1) { $index++ }
    }
    elseif ($key.Key -in 'k', 'K', 'UpArrow') {
      if ($index -gt 0) { $index-- }
    }
    elseif ($key.Key -eq 'Spacebar') {
      $Items[$index].Enabled = -not $Items[$index].Enabled
    }
    elseif ($key.Key -eq 'Enter') {
      :ConfirmLoop while ($true) {
        Clear-Host
        Write-Host "Current selection:`n"

        foreach ($item in $Items) {
          $check = if ($item.Enabled) { '[x]' } else { '[ ]' }
          Write-Host "$check $($item.Name)"
        }

        Write-Host ""
        Write-Host "Apply these settings? (y = yes, n = no, q = quit)"

        $confirmKey = [System.Console]::ReadKey($true)

        switch ($confirmKey.KeyChar) {
          'y' { return $Items }
          'Y' { return $Items }

          'n' { break ConfirmLoop }
          'N' { break ConfirmLoop }

          'q' { exit 0 }
          'Q' { exit 0 }
        }
      }
    }
  }

  return $Items
}

$wingetPkgs = Show-Menu -Items $wingetAllPkgs
$wingetPkgs = $wingetPkgs | Where-Object Enabled

$configFiles = Show-Menu -Items $configAll
$configFiles = $configFiles | Where-Object Enabled
$cloneAndRun = @'
git clone https://github.com/T1mberland/init.lua.git "$env:LOCALAPPDATA\nvim"
nvim
'@

foreach ($id in $wingetPkgs) {
  Write-Host "Downloading and installing $($id.Name)..."
  winget install --id "$($id.Name)" -e --source winget --accept-source-agreements --accept-package-agreements
}

foreach ($configFile in $configFiles) {
  if ($configFile.Name -eq 'Neovim (~/AppData/Local/nvim/init.lua)') {
    if (Test-Path "$env:LOCALAPPDATA\nvim") {
      Write-Host "Directory $env:LOCALAPPDATA\nvim already exists."
      $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
      Write-Host "Moving $env:LOCALAPPDATA\nvim to $env:LOCALAPPDATA\nvim_$timestamp"
      Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim_$timestamp
    }

    Write-Host "Cloning Neovim config and launching Neovim..." 
    Start-Process powershell.exe -ArgumentList '-NoExit', '-Command', $cloneAndRun
  }
  elseif ($configFile.Name -eq 'AutoHotKey (~/Desktop/keybindings.ahk)') {
    Write-Host "Downloading AutoHotKey keybindings..."
    Invoke-WebRequest `
      'https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/keybindings.ahk' `
      -OutFile "$HOME/Desktop/keybindings.ahk"
  }
  elseif ($configFile.Name -eq 'Wezterm (~/.wezterm.lua)') {
    Write-Host "Downloading Wezterm config..."
    Invoke-WebRequest `
      'https://raw.githubusercontent.com/T1mberland/bootstrap/refs/heads/master/.wezterm.lua' `
      -OutFile "$HOME/.wezterm.lua"
  }
}
