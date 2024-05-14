Write-Host "Importing the file " -NoNewline
Write-Host $(( $MyInvocation.MyCommand.Definition ).Split("\")[-1]) -ForegroundColor Green

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
