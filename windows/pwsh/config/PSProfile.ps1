#------------------------------------------------------------------#
# Variable Declearation
#------------------------------------------------------------------#
$PwshProfile = "$($MyInvocation.MyCommand.Definition | Split-Path)\$PSEdition"
$ConfigurationFiles = Get-ChildItem -Path $PwshProfile
$ConfigurationList = @(
  "PSReadLine",
  "Terminal-Icons",
  "Starship",
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
      . ($ConfigurationFiles | Where-Object {$_.BaseName -like $Configuration}).FullName
    }
  }
  catch {

  }
}

#------------------------------------------------------------------#
# Invoke Starship Prompt
#------------------------------------------------------------------#

Invoke-Expression (&starship init powershell)
