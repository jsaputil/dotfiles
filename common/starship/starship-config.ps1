try {
  $NewItemSymbolicLinkSplash = @{
    "ItemType" = "SymbolicLink"
    "Path" = "$HOME\.config\starship.toml" 
    "Value" = $(Resolve-Path ~\.dotfiles\common\starship\starship.toml)
    "ErrorAction" = "Stop"
  } ; New-Item @NewItemSymbolicLinkSplash | Out-Null 
}
catch [System.IO.IOException] {
  Write-Host "SymbolicLink already exists"
}
catch {
  Write-Host "Could not create new SymbolicLink"
}

try {
  $FindStr = Get-Content -Path $PROFILE.CurrentUserCurrentHost | 
    Select-String -Pattern "Invoke-Expression \(&starship init powershell\)"
  if (!($FindStr -is [System.Object])) {
    $AddContentSplat = @{
      "Path" = "$($PROFILE.CurrentUserCurrentHost)"
      "Value" = "Invoke-Expression (&starship init powershell)"
    } ; Add-Content @AddContentSplat
    Write-Host "Starship startup script applied"
  }
  else {
    Write-Host "Starship startup script already applied"
  }
}
catch {
  Write-Host "Could not write configuration to powershell profile"
}


