#------------------------------------------------------------------#
# Variable Declearation
#------------------------------------------------------------------#
$PwshProfile = "$($MyInvocation.MyCommand.Definition | Split-Path)\$PSEdition"
$ConfigurationFiles = Get-ChildItem -Path $PwshProfile
$ConfigurationList = @(
  "Starship",
  "Terminal-Icons",
  "PSReadLine",
  "UserProfile"
)

#------------------------------------------------------------------#
# Check App Powershell Configuration
#------------------------------------------------------------------#
foreach ($Configuration in $ConfigurationList) {
  try {
    if (($ConfigurationFiles | Where-Object {$_.BaseName -like $Configuration}) -like $null) {
      continue
    }
    else {
      . ($ConfigurationFiles | Where-Object {$_.BaseName -like $Configuration})
    }
  }
  catch {
    
  }
}


#foreach ($Module in $Modules.GetEnumerator()) {
#  if ($Module.Value -eq "Latest") {
#    Import-Module -Name $Module.Name -Debug
#  }
#  else {
#    $ModuleSpecification = [Microsoft.PowerShell.Commands.ModuleSpecification]@{
#      "ModuleName" = $Module.Name
#      "ModuleVersion" = $Module.Value
#    }
#    if (Get-Module -ListAvailable | 
#      Where-Object {( $_.Name -eq $ModuleSpecification.Name ) -and ($_.Version -eq $ModuleSpecification.Version)}) {
#      Import-Module -FullyQualifiedName $ModuleSpecification -Debug
#    }
#    else {
#      Write-Host "Module $($ModuleSpecification.Name) version $($ModuleSpecification.Version) was not found."
#    }
#  }
#}

