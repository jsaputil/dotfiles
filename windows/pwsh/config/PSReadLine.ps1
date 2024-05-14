#-------------------------------------------------
# File Importing Annoucer 
#-------------------------------------------------

Write-Host "Importing the file " -NoNewline
Write-Host $(( $MyInvocation.MyCommand.Definition ).Split("\")[-1]) -ForegroundColor Green

#-------------------------------------------------
# PowerShell Module Version Manager
#-------------------------------------------------

$Module = @{
  "PSReadLine" = "Latest"
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

#-------------------------------------------------
# PSReadLine Module Configuration
#-------------------------------------------------

Set-PSReadLineKeyHandler -Key ')',']','}' `
  -BriefDescription SmartCloseBraces `
  -LongDescription "Insert closing brace or skip" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($line[$cursor] -eq $key.KeyChar)
  {
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  } else
  {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
  }
}

Set-PSReadLineKeyHandler -Key '(','{','[' `
  -BriefDescription InsertPairedBraces `
  -LongDescription "Insert matching braces" `
  -ScriptBlock {
  param($key, $arg)

  $closeChar = switch ($key.KeyChar)
  {
    <#case#> '('
    { [char]')'; break 
    }
    <#case#> '{'
    { [char]'}'; break 
    }
    <#case#> '['
    { [char]']'; break 
    }
  }

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
  if ($selectionStart -ne -1)
  {
    # Text is selected, wrap it in brackets
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  } else
  {
    # No text is selected, insert a pair
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  }
}

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
