# Setup development environment for building the LaTeX document with lualatex and rendering Mermaid diagrams.
# This script will attempt to install Node.js (if missing), mermaid-cli, and suggest/install a TeX distribution that provides lualatex.
# NOTE: Requires administrative privileges for package managers (choco/winget). Run PowerShell as Administrator if you want automatic installs.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "Repository scripts directory: $scriptDir"

function Install-NpmPackageGlobal($pkg) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Warning "npm not found. Please install Node.js first."
        return 1
    }
    Write-Host "Installing npm package: $pkg"
    & npm install -g $pkg
    return $LASTEXITCODE
}

# 1) Ensure Node.js (and npm)
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
    Write-Host "Node.js found: $($node.Path)"
} else {
    Write-Warning "Node.js not found. Attempting automatic install (using choco or winget)"
    $choco = Get-Command choco -ErrorAction SilentlyContinue
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($choco) {
        Write-Host "Installing Node.js using choco (admin privileges may be required): choco install nodejs -y"
        choco install nodejs -y
    } elseif ($winget) {
        Write-Host "Installing Node.js using winget: winget install OpenJS.NodeJS"
        winget install --id OpenJS.NodeJS -e --source winget
    } else {
        Write-Host "No package manager (choco/winget) found. Please install Node.js manually: https://nodejs.org/"
    }
}

# 2) Install mermaid-cli
Write-Host "Installing mermaid-cli (@mermaid-js/mermaid-cli) via npm..."
Install-NpmPackageGlobal "@mermaid-js/mermaid-cli"

# 3) Provide instructions / attempt to install lualatex (MiKTeX)
$lualatex = Get-Command lualatex -ErrorAction SilentlyContinue
if ($lualatex) {
    Write-Host "lualatex found: $($lualatex.Path)"
} else {
    Write-Warning "lualatex not found. A TeX distribution is required (MiKTeX or TeX Live)."
    $choco = Get-Command choco -ErrorAction SilentlyContinue
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($choco) {
        Write-Host "choco detected. Installing MiKTeX (admin privileges required): choco install miktex -y"
        choco install miktex -y
        Write-Host "After installing MiKTeX, open MiKTeX Console and update packages as needed (ensure lualatex is available)."
    } elseif ($winget) {
        Write-Host "winget detected. Installing MiKTeX: winget install MiKTeX.MiKTeX"
        winget install --id MiKTeX.MiKTeX -e --source winget
    } else {
        Write-Host "Automatic install not available. Please install one of the following manually:"
        Write-Host " - MiKTeX: https://miktex.org/download"
        Write-Host " - TeX Live: http://tug.org/texlive/"
    }
}

Write-Host "Setup script finished. Run scripts\build_lualatex.ps1 to build the document."
