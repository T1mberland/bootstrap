$ErrorActionPreference = 'Stop'

# 同期したい repo 一覧
$repos = @(
  "C:\Users\user\Documents\repo01"
  "C:\Users\user\Documents\repo02"
)

# 失敗したくないのでプロンプト禁止（資格情報は事前に保存しておく: GCM or SSH）
$env:GIT_TERMINAL_PROMPT = "0"

$git = "C:\Program Files\Git\cmd\git.exe"

foreach ($r in $repos) {
  try {
    Write-Host "[REPO] : " -ForegroundColor Yellow -NoNewline
    Write-Host "$r"
    Write-Host "Start syncing..."
    # Write-Output "syncing: $r"

    Write-Host "[FETCH] : " -ForegroundColor Yellow -NoNewline
    Write-Host "$r"
    & $git -C $r fetch --prune
    Write-Host "[PULL] : " -ForegroundColor Yellow -NoNewline
    Write-Host "$r"
    & $git -C $r pull --rebase --autostash

    Write-Host "[ADD] : " -ForegroundColor Yellow -NoNewline
    Write-Host "$r"
    & $git -C $r add -A

    & $git -C $r diff --cached --quiet
    $hasChanges = -not $?

    if ($hasChanges) {
      $msg = "[auto] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
      Write-Host "[COMMIT] : " -ForegroundColor Yellow -NoNewline
      Write-Host "$r, $msg"
      & $git -C $r commit -m $msg
      Write-Host "[PUSH] : " -ForegroundColor Yellow -NoNewline
      Write-Host "$r"
      & $git -C $r push
    } else {
      Write-Host "[SKIP] : " -ForegroundColor Cyan -NoNewline
      Write-Host "$r"
      Write-Output "no staged changes in $r"
    }
  } catch {
    Write-Host "[ERROR] : " -ForegroundColor Yellow -NoNewline
    Write-Host "${r}"
    Write-Output "$($_.Exception.Message)"
  }
}

 "==== $(Get-Date) end ===="

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
