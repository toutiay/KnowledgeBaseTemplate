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

function Join-Chars([int[]]$Codes) {
  return -join ($Codes | ForEach-Object { [char]$_ })
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

$indexName = Join-Chars @(0x7D22, 0x5F15)
$sourceName = Join-Chars @(0x6765, 0x6E90)
$topicName = Join-Chars @(0x4E3B, 0x9898)
$conceptName = Join-Chars @(0x6982, 0x5FF5)
$processName = Join-Chars @(0x6D41, 0x7A0B)
$comparisonName = Join-Chars @(0x5BF9, 0x6BD4)

$dirs = @(
  "raw",
  "wiki",
  "wiki\00 $indexName",
  "wiki\10 $sourceName",
  "wiki\20 $topicName",
  "wiki\30 $conceptName",
  "wiki\40 $processName",
  "wiki\50 $comparisonName",
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
