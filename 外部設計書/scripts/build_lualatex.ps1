# Build script that renders Mermaid and compiles the LaTeX project with lualatex
# Usage: Run from repository root or run this script directly in PowerShell.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path "$scriptDir\.."
Set-Location $repoRoot

Write-Host "Working directory: $repoRoot"

# 1) Render Mermaid ER diagram
Write-Host "Step 1: Rendering Mermaid diagram..."
& "$scriptDir\render_mermaid.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Mermaid rendering failed or was not completed. Please check scripts\render_mermaid.ps1 output."
}

# 2) Find lualatex
$lualatex = Get-Command lualatex -ErrorAction SilentlyContinue
if (-not $lualatex) {
    Write-Warning "lualatex が見つかりません。\n -> 事前に scripts\setup_env.ps1 を実行してインストールするか、MiKTeX/TeX Live を手動でインストールしてください。"
    exit 1
}

# 3) Compile with lualatex (multiple passes)
Write-Host "Step 2: Running lualatex (2 passes)..."
& $lualatex.Source -interaction=nonstopmode main.tex | Write-Host
if ($LASTEXITCODE -ne 0) { Write-Warning "lualatex initial pass failed (exit $LASTEXITCODE)" }
& $lualatex.Source -interaction=nonstopmode main.tex | Write-Host
if ($LASTEXITCODE -ne 0) { Write-Warning "lualatex second pass failed (exit $LASTEXITCODE)" }

Write-Host "Build finished. 出力を確認してください: main.pdf"
