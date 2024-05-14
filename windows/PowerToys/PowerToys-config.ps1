# Declear Variables
$DOTFILES_ROOT = $($MyInvocation.MyCommand.Definition | Split-Path | Split-Path | Split-Path)
$GITHUB_USER = "microsoft"
$GITHUB_REPOSITORY = "PowerToys"
$GITHUB_APIKEY = (Get-Content -Path "$DOTFILES_ROOT\.env" | 
  Select-String GITHUB_APIKEY ).ToString().Split("=")[-1]
$INSTALL_PATH = "$env:LOCALAPPDATA\$GITHUB_REPOSITORY"

# Operations
if (!(Test-Path $INSTALL_PATH)) {
  New-Item -Path $INSTALL_PATH -ItemType Directory
}

$LatestRelease = @{
  "URI" = "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPOSITORY/releases/latest"
  "Headers" = @{"Authorization" = "token $GITHUB_APIKEY"}
  "Method" = "Get"
} ; $LatestRelease = Invoke-RestMethod @LatestRelease

# Filter which asset to be downloaded in list of asset
$Assets = $LatestRelease.assets | 
  Where-Object {( $_.Name -like "*PowerToysSetup*" ) -and ( $_.Name -like "*x64*" )}

# Check new release
if (Test-Path "$INSTALL_PATH\$($Assets.Name)") {
  Write-Host "Latest version already installed."
}
else {
  Write-Host "New version available. Updating..."
  
  # Download asset
  Invoke-WebRequest -Uri $Assets.browser_download_url -OutFile "$INSTALL_PATH\$($Assets.Name)"

  # Unzip the asset
  Expand-Archive -Path "$INSTALL_PATH\$($Assets.Name)" -DestinationPath $INSTALL_PATH -Force

  # Remove the zip file
  Remove-Item -Path "$INSTALL_PATH\$($Assets.Name)"

  Write-Host "Update completed!"
}

