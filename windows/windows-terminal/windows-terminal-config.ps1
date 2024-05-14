if ((Get-Command -Name wt).Source -like "*WindowsApps\wt.exe") {
  Write-Host "Windows Terminal already installed on path " -NoNewline
  Write-Host (Get-Command -Name wt).Source -ForegroundColor Green
  Write-Host "Applying terminal settings from .dotfiles repo"
  try {
    $NewItemSymbolicLinkSplash = @{
      "ItemType" = "SymbolicLink"
      "Path" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
      "Value" = $(Resolve-Path ~\.dotfiles\windows\windows-terminal\settings.json)
      "ErrorAction" = "Stop"
      "Force" = $true } 
    Write-Host "Generated symbolic link for file " -NoNewline
    Write-Host "$((New-Item @NewItemSymbolicLinkSplash).Name) " -ForegroundColor Green
  }
  catch [System.IO.IOException] {
    Write-Host "SymbolicLink already exists"
  }
  catch {
    Write-Host "Could not create new SymbolicLink"
  }
}
else {
  if ((scoop list windows-terminal).Name -notlike "windows-terminal") {
    Write-Host "The app: " -NoNewline
    Write-Host "windows-terminal" -ForegroundColor Red -NoNewline
    Write-Host " is not installed."
    Write-Host "Initiating installation using scoop"
    scoop install windows-terminal
    try {
      $NewItemSymbolicLinkSplash = @{
        "ItemType" = "SymbolicLink"
        "Path" = "$env:USERPROFILE\scoop\apps\windows-terminal\current\settings.json"
        "Value" = $(Resolve-Path ~\.dotfiles\windows\windows-terminal\settings.json)
        "ErrorAction" = "Stop"
      } ; New-Item @NewItemSymbolicLinkSplash | Out-Null 
    }
    catch [System.IO.IOException] {
      Write-Host "SymbolicLink already exists"
    }
    catch {
      Write-Host "Could not create new SymbolicLink"
    } 
  }
}
