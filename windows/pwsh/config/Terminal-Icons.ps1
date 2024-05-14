#-------------------------------------------------
# File Importing Annoucer 
#-------------------------------------------------

Write-Host "Importing the file " -NoNewline
Write-Host $(( $MyInvocation.MyCommand.Definition ).Split("\")[-1]) -ForegroundColor Green

#-------------------------------------------------
# PowerShell Module Version Manager
#-------------------------------------------------

$Module = @{
  "Terminal-Icons" = "Latest"
}
 
if ($Module.Values -eq "Latest") {
  try {
    Import-Module -Name $Module.Keys -ErrorAction Stop
    $CurrentModuleVersion = (Get-Module -Name $Module.Keys).Version.ToString()
    $LatestModuleVersion = (Find-Module -Name $Module.Keys).Version.ToString()
    if (!($CurrentModuleVersion -eq $LatestModuleVersion)) {
      Write-Host "  | Removing old module $($Module.Keys) - version: $CurrentModuleVersion"
      Remove-Module -Name $Module.Keys -Force
      Write-Host "  | Uninstalling $($Module.Keys) - version: $CurrentModuleVersion"
      Uninstall-Module -Name $Module.Keys -Force
      Write-Host "  | Installing $($Module.Keys) - version: $LatestModuleVersion"
      Install-Module -Name $Module.Keys -Repository PSGallery -Force
      Import-Module -Name $Module.Keys -Force -ErrorAction Stop 
    }
  }
  catch {
    Write-Host "  | Could not find module $($Module.Keys)"
    Write-Host "  | Attempting to install $($Module.Keys)"
    Install-Module -Name $Module.Keys -Repository PSGallery -Force
    Write-Host "  | Successfully installed module $($Module.Keys)"
    try {
      Write-Host "  | Attempting to import newly installed module $($Module.Keys)"
      Import-Module -Name $Module.Keys -Force -ErrorAction Stop 
      $CurrentModuleVersion = (Get-Module -Name $Module.Keys).Version.ToString()
      Write-Host "  | Successfully imported newly installed module: " -NoNewline
      Write-Host "$($Module.Keys) v: $CurrentModuleVersion" -ForegroundColor Green
    }
    catch {
      Write-Host "  | Could not import the newly installed module $($Module.Keys) - version: $CurrentModuleVersion"
    }
  }
}

else {
  [Microsoft.PowerShell.Commands.ModuleSpecification]$ModuleSpecification = @{
    "ModuleName" = $Module.Keys
    "ModuleVersion" = $Module.Values
  }
  
  if (Get-Module -ListAvailable | Where-Object {( $_.Name -eq $ModuleSpecification.Name ) -and ($_.Version -eq $ModuleSpecification.Version)}) {
    Import-Module -FullyQualifiedName $ModuleSpecification
    Write-Host "Module " -NoNewline
    Write-Host $($ModuleSpecification.Name) -ForegroundColor Green -NoNewline
    Write-Host ", version " -NoNewline
    Write-Host $($ModuleSpecification.Version) -ForegroundColor Green -NoNewline
    Write-Host " was imported."
  } 
  
  else {
    Write-Host "Module " -NoNewline
    Write-Host $($ModuleSpecification.Name) -ForegroundColor Red -NoNewline
    Write-Host ", version " -NoNewline
    Write-Host $($ModuleSpecification.Version) -ForegroundColor Red -NoNewline
    Write-Host " was not imported."
  }
}

#-------------------------------------------------
# PSReadLine Module Configuration
#-------------------------------------------------

