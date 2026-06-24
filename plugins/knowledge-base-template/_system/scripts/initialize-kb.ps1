param(
  [string]$Root,
  [switch]$UseDefault
)

$ErrorActionPreference = "Stop"

function Get-ConfigPath {
  return Join-Path $env:USERPROFILE ".codex\knowledge-base-template\config.json"
}

function Get-DefaultKnowledgeBaseRoot {
  if ($env:CODEX_KB_HOME) {
    return $env:CODEX_KB_HOME
  }
  return Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Codex\KnowledgeBase"
}

if ([string]::IsNullOrWhiteSpace($Root)) {
  $defaultRoot = Get-DefaultKnowledgeBaseRoot
  if ($UseDefault) {
    $root = $defaultRoot
  } else {
    Write-Output "Please choose the knowledge base storage directory."
    Write-Output "Press Enter to use the default:"
    Write-Output $defaultRoot
    $answer = Read-Host "Knowledge base directory"
    if ([string]::IsNullOrWhiteSpace($answer)) {
      $root = $defaultRoot
    } else {
      $root = $answer
    }
  }
} else {
  $root = $Root
}

if (-not [IO.Path]::IsPathRooted($root)) {
  $root = Join-Path (Get-Location) $root
}

$root = [IO.Path]::GetFullPath($root)

$dirs = @(
  "raw",
  "wiki",
  "wiki\00-index",
  "wiki\10-source",
  "wiki\20-topic",
  "wiki\30-concept",
  "wiki\40-process",
  "wiki\50-comparison",
  "context"
)

foreach ($dir in $dirs) {
  $path = Join-Path $root $dir
  if (-not (Test-Path -LiteralPath $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
  }
}

$configPath = Get-ConfigPath
$configDir = Split-Path -Parent $configPath
if (-not (Test-Path -LiteralPath $configDir)) {
  New-Item -ItemType Directory -Path $configDir | Out-Null
}

$config = [ordered]@{
  knowledgeBaseRoot = $root
}
$config | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding utf8

Write-Output "Knowledge base initialized"
Write-Output "root: $root"
Write-Output "config: $configPath"
