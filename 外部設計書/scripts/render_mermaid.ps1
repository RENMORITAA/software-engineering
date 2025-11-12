# Render Mermaid diagram to PDF/PNG using mermaid-cli (mmdc)
# Usage (PowerShell):
#   .\scripts\render_mermaid.ps1
# If mmdc is not found, install globally:
#   npm install -g @mermaid-js/mermaid-cli

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path "$scriptDir\.."
$mmdIn = "$repoRoot\Image\database_er.mmd"
$pdfOut = "$repoRoot\Image\database_er.pdf"
$pngOut = "$repoRoot\Image\database_er.png"

Write-Host "Mermaid source: $mmdIn"

# Check input exists
if (-not (Test-Path $mmdIn)) {
    Write-Error "Mermaid source not found: $mmdIn"
    exit 2
}

# Find mmdc
$mmdc = Get-Command mmdc -ErrorAction SilentlyContinue
if (-not $mmdc) {
    Write-Warning "mermaid-cli (mmdc) が見つかりません。"
    Write-Host "インストール方法 (Node.js が必要です)："
    Write-Host "  npm install -g @mermaid-js/mermaid-cli"
    exit 1
}

# Try to produce PDF (preferred for pdflatex)
Write-Host "Rendering PDF -> $pdfOut"
& $mmdc.Source -i $mmdIn -o $pdfOut 2>&1 | Write-Host
if ($LASTEXITCODE -eq 0 -and (Test-Path $pdfOut)) {
    Write-Host "生成成功: $pdfOut"
    exit 0
}

# Fallback to PNG
Write-Host "PDF生成に失敗したためPNGで出力 -> $pngOut"
& $mmdc.Source -i $mmdIn -o $pngOut 2>&1 | Write-Host
if ($LASTEXITCODE -eq 0 -and (Test-Path $pngOut)) {
    Write-Host "生成成功: $pngOut"
    exit 0
}

Write-Error "図の生成に失敗しました。mmdc 出力を確認してください。"
exit 3
