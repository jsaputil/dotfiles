if ($PSVersionTable.PSEdition -ne "Core") {
  if ($null -ne (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    pwsh.exe -File $($MyInvocation.MyCommand.Definition)
    exit
  }
  else {
    Write-Host "Powershell Core (pwsh) is not available, please install the shell."
    exit
  }
}

$NewItemSymbolicLinkSplash = @{
  "ItemType" = "SymbolicLink"
  "Path" = "$($PROFILE.CurrentUserCurrentHost)"
  "Value" = $(Resolve-Path ~\.dotfiles\windows\pwsh\config\PSProfile.ps1)
  "ErrorAction" = "Stop"
  "Force" = $true
} ; New-Item @NewItemSymbolicLinkSplash | Out-Null
Write-Host "New symlink at path: " -NoNewline
Write-Host "$($PROFILE.CurrentUserCurrentHost)" -ForegroundColor Green

$NewItemSymbolicLinkSplash = @{
  "ItemType" = "SymbolicLink"
  "Path" = "$($PROFILE.CurrentUserCurrentHost | Split-Path)\$PSEdition"
  "Value" = $(Resolve-Path ~\.dotfiles\windows\pwsh\config)
  "ErrorAction" = "Stop"
  "Force" = $true
} ; New-Item @NewItemSymbolicLinkSplash | Out-Null

Write-Host "New symlink at path: " -NoNewline
Write-Host "$($PROFILE.CurrentUserCurrentHost | Split-Path)\$PSEdition" -ForegroundColor Green


