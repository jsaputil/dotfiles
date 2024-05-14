Write-Host "Importing the file " -NoNewline
Write-Host $(( $MyInvocation.MyCommand.Definition ).Split("\")[-1]) -ForegroundColor Green


Invoke-Expression (&starship init powershell)
