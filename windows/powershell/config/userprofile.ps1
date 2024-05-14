Write-Host "Importing the file " -NoNewline
Write-Host $(( $MyInvocation.MyCommand.Definition ).Split("\")[-1]) -ForegroundColor Green

# PSReadLine Module
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -BellStyle None

# FuzzyFinder
Set-PSFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Alias
Set-Alias vim nvim	
Set-Alias ll ls

# Alias - Git
Set-Alias tig $env:USERPROFILE\AppData\Local\Programs\Git\usr\bin\tig.exe
Set-Alias less $env:USERPROFILE\AppData\Local\Programs\Git\usr\bin\less.exe
Set-Alias g git
