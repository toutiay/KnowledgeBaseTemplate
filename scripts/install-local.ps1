param(
  [string]$KnowledgeBaseRoot,
  [switch]$UseDefaultKnowledgeBaseRoot
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $repoRoot "plugins\knowledge-base-template"
$initScript = Join-Path $pluginRoot "_system\scripts\initialize-kb.ps1"

function Get-CodexCli {
  $appServerCli = Join-Path $env:USERPROFILE ".codex\plugins\.plugin-appserver\codex.exe"
  if (Test-Path -LiteralPath $appServerCli) {
    return $appServerCli
  }

  $command = Get-Command codex -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  throw "Unable to find Codex CLI. Expected codex on PATH or $appServerCli."
}

$codex = Get-CodexCli

Write-Output "Installing knowledge-base-template plugin..."
& $codex plugin add knowledge-base-template@personal

Write-Output ""
Write-Output "Configuring knowledge base storage..."
if (-not [string]::IsNullOrWhiteSpace($KnowledgeBaseRoot)) {
  & powershell -ExecutionPolicy Bypass -File $initScript -Root $KnowledgeBaseRoot
} elseif ($UseDefaultKnowledgeBaseRoot) {
  & powershell -ExecutionPolicy Bypass -File $initScript -UseDefault
} else {
  & powershell -ExecutionPolicy Bypass -File $initScript
}

Write-Output ""
Write-Output "Installation complete. Open a new Codex thread so the updated skill is loaded."
