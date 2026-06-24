param(
  [string]$Root,
  [switch]$StrictSchema
)

$ErrorActionPreference = "Stop"

function Get-DefaultKnowledgeBaseRoot {
  if ($env:CODEX_KB_HOME) {
    return $env:CODEX_KB_HOME
  }
  return Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Codex\KnowledgeBase"
}

function Get-ConfiguredKnowledgeBaseRoot {
  $configPath = Join-Path $env:USERPROFILE ".codex\knowledge-base-template\config.json"
  if (-not (Test-Path -LiteralPath $configPath)) {
    return $null
  }

  try {
    $config = Get-Content -LiteralPath $configPath -Raw -Encoding utf8 | ConvertFrom-Json
    if ($config.knowledgeBaseRoot -and -not [string]::IsNullOrWhiteSpace($config.knowledgeBaseRoot)) {
      return $config.knowledgeBaseRoot
    }
  } catch {
    Write-Warning "Unable to read knowledge base config: $configPath"
  }

  return $null
}

if ([string]::IsNullOrWhiteSpace($Root)) {
  $configuredRoot = Get-ConfiguredKnowledgeBaseRoot
  if ($configuredRoot) {
    $root = $configuredRoot
  } else {
    $root = Get-DefaultKnowledgeBaseRoot
  }
} else {
  $root = $Root
}

if (-not [IO.Path]::IsPathRooted($root)) {
  $root = Join-Path (Get-Location) $root
}

$root = [IO.Path]::GetFullPath($root)
$wiki = Join-Path $root "wiki"
$raw = Join-Path $root "raw"

function Get-RelativePath([string]$path) {
  return $path.Substring($root.Length + 1)
}

function Get-Frontmatter([string]$text) {
  if ($text -notmatch "(?s)^---\r?\n(.*?)\r?\n---") {
    return $null
  }

  $map = @{}
  foreach ($line in ($Matches[1] -split "\r?\n")) {
    if ($line -match "^\s*([A-Za-z_][A-Za-z0-9_-]*)\s*:") {
      $map[$Matches[1]] = $true
    }
  }
  return $map
}

function Get-FrontmatterValue([string]$text, [string]$key) {
  if ($text -match "(?m)^\s*$([regex]::Escape($key))\s*:\s*(.+?)\s*$") {
    return $Matches[1].Trim().Trim('"').Trim("'")
  }
  return $null
}

function Test-RawTarget([string]$rawLink) {
  $normalized = $rawLink -replace "\\", "/"
  $normalized = $normalized -replace "^\.\./\.\./raw/", ""
  $normalized = $normalized -replace "^\.\./raw/", ""
  $candidate = Join-Path $raw ($normalized -replace "/", [IO.Path]::DirectorySeparatorChar)

  if (Test-Path -LiteralPath $candidate) { return $true }
  if (Test-Path -LiteralPath "$candidate.md") { return $true }
  if (Test-Path -LiteralPath "$candidate.pdf") { return $true }
  return $false
}

$missingDirs = @()
if (-not (Test-Path -LiteralPath $raw)) { $missingDirs += "raw" }
if (-not (Test-Path -LiteralPath $wiki)) { $missingDirs += "wiki" }

$wikiDirs = @{}
if (Test-Path -LiteralPath $wiki) {
  foreach ($dir in Get-ChildItem -LiteralPath $wiki -Directory) {
    if ($dir.Name.Length -ge 2) {
      $wikiDirs[$dir.Name.Substring(0, 2)] = $dir.FullName
    }
  }
}

$wikiSections = @{
  "00" = @{
    Name = -join ([char[]](0x7D22, 0x5F15))
    Type = "index"
    Aliases = @(
      -join ([char[]](0x7D22, 0x5F15)),
      -join ([char[]](0x7D22, 0x5F15, 0x9875))
    )
  }
  "10" = @{
    Name = -join ([char[]](0x6765, 0x6E90))
    Type = "source"
    Aliases = @(
      -join ([char[]](0x6765, 0x6E90)),
      -join ([char[]](0x6765, 0x6E90, 0x9875))
    )
  }
  "20" = @{
    Name = -join ([char[]](0x4E3B, 0x9898))
    Type = "topic"
    Aliases = @(
      -join ([char[]](0x4E3B, 0x9898)),
      -join ([char[]](0x4E3B, 0x9898, 0x9875))
    )
  }
  "30" = @{
    Name = -join ([char[]](0x6982, 0x5FF5))
    Type = "concept"
    Aliases = @(
      -join ([char[]](0x6982, 0x5FF5)),
      -join ([char[]](0x6982, 0x5FF5, 0x9875))
    )
  }
  "40" = @{
    Name = -join ([char[]](0x6D41, 0x7A0B))
    Type = "process"
    Aliases = @(
      -join ([char[]](0x6D41, 0x7A0B)),
      -join ([char[]](0x6D41, 0x7A0B, 0x9875))
    )
  }
  "50" = @{
    Name = -join ([char[]](0x5BF9, 0x6BD4))
    Type = "comparison"
    Aliases = @(
      -join ([char[]](0x5BF9, 0x6BD4)),
      -join ([char[]](0x5BF9, 0x6BD4, 0x9875))
    )
  }
}

$sourceNamePrefix = $wikiSections["10"].Name + " - "
$indexNamePrefix = $wikiSections["00"].Name + " - "

foreach ($prefix in $wikiSections.Keys) {
  if (-not $wikiDirs.ContainsKey($prefix)) {
    $missingDirs += "wiki/$prefix $($wikiSections[$prefix].Name)"
  }
}

$wikiFiles = @()
if (Test-Path -LiteralPath $wiki) {
  $wikiFiles = Get-ChildItem -LiteralPath $wiki -Recurse -File -Filter "*.md"
}

$wikiNames = @{}
foreach ($file in $wikiFiles) {
  $name = $file.Name
  if ($name.EndsWith(".md")) {
    $wikiNames[$name.Substring(0, $name.Length - 3)] = $true
  }
}

$brokenWikiLinks = @()
$brokenRawLinks = @()
$schemaIssues = @()
$typeDirectoryIssues = @()
$namingIssues = @()

$requiredWikiFields = @("title", "type", "status", "confidence", "updated", "sources")

foreach ($file in $wikiFiles) {
  $relative = Get-RelativePath $file.FullName
  $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
  $frontmatter = Get-Frontmatter $text

  if ($null -eq $frontmatter) {
    $schemaIssues += [pscustomobject]@{ File = $relative; Issue = "missing frontmatter" }
  } else {
    foreach ($field in $requiredWikiFields) {
      if (-not $frontmatter.ContainsKey($field)) {
        $schemaIssues += [pscustomobject]@{ File = $relative; Issue = "missing field: $field" }
      }
    }
  }

  $prefix = $file.Directory.Name.Substring(0, [Math]::Min(2, $file.Directory.Name.Length))
  if ($wikiSections.ContainsKey($prefix)) {
    $expectedType = $wikiSections[$prefix].Type
    $actualType = Get-FrontmatterValue $text "type"
    if ($actualType) {
      $validTypes = @($expectedType)
      $validTypes += $wikiSections[$prefix].Aliases
      if ($validTypes -notcontains $actualType) {
        $typeDirectoryIssues += [pscustomobject]@{ File = $relative; Expected = $expectedType; Actual = $actualType }
      }
    }
  }

  if ($prefix -eq "10" -and -not $file.BaseName.StartsWith($sourceNamePrefix)) {
    $namingIssues += [pscustomobject]@{ File = $relative; Issue = "source page should start with source prefix" }
  }
  if ($prefix -eq "00" -and -not $file.BaseName.StartsWith($indexNamePrefix)) {
    $namingIssues += [pscustomobject]@{ File = $relative; Issue = "index page should start with index prefix" }
  }

  foreach ($match in [regex]::Matches($text, "\[\[([^\]|#]+)")) {
    $link = $match.Groups[1].Value
    if ($link -match "^\.\.?/.*raw/") {
      if (-not (Test-RawTarget $link)) {
        $brokenRawLinks += [pscustomobject]@{ File = $relative; Raw = $link }
      }
      continue
    }

    $target = Split-Path $link -Leaf
    if (-not $wikiNames.ContainsKey($target)) {
      $brokenWikiLinks += [pscustomobject]@{ File = $relative; Link = $link }
    }
  }
}

$sourceDir = $wikiDirs["10"]
$sourcePages = @()
if ($sourceDir) {
  $sourcePages = Get-ChildItem -LiteralPath $sourceDir -File -Filter "*.md"
}

$sourcePagesWithoutRaw = @()
foreach ($file in $sourcePages) {
  $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
  $matches = [regex]::Matches($text, "\[\[((?:\.\./|\.\./\.\./)raw/[^\]|#]+)")
  if ($matches.Count -eq 0) {
    $sourcePagesWithoutRaw += Get-RelativePath $file.FullName
  }
}

$rawMarkdownCount = 0
if (Test-Path -LiteralPath $raw) {
  $rawMarkdownCount = (Get-ChildItem -LiteralPath $raw -File -Filter "*.md").Count
}

Write-Output "KB validation"
Write-Output "-------------"
Write-Output "root: $root"
Write-Output "raw markdown files: $rawMarkdownCount"
Write-Output "wiki pages: $($wikiFiles.Count)"
Write-Output "source pages: $($sourcePages.Count)"
Write-Output "missing required dirs: $($missingDirs.Count)"
Write-Output "broken wiki links: $($brokenWikiLinks.Count)"
Write-Output "source pages without raw link: $($sourcePagesWithoutRaw.Count)"
Write-Output "broken raw links: $($brokenRawLinks.Count)"
Write-Output "schema warnings: $($schemaIssues.Count)"
Write-Output "type/directory issues: $($typeDirectoryIssues.Count)"
Write-Output "naming issues: $($namingIssues.Count)"

$hasErrors = $missingDirs.Count -or $brokenWikiLinks.Count -or $sourcePagesWithoutRaw.Count -or $brokenRawLinks.Count -or $typeDirectoryIssues.Count -or $namingIssues.Count -or ($StrictSchema -and $schemaIssues.Count)

if ($hasErrors) {
  if ($missingDirs.Count) {
    Write-Output ""
    Write-Output "Missing required dirs:"
    $missingDirs | ForEach-Object { Write-Output "  - $_" }
  }
  if ($brokenWikiLinks.Count) {
    Write-Output ""
    Write-Output "Broken wiki links:"
    $brokenWikiLinks | Format-Table -AutoSize
  }
  if ($sourcePagesWithoutRaw.Count) {
    Write-Output ""
    Write-Output "Source pages without raw link:"
    $sourcePagesWithoutRaw | ForEach-Object { Write-Output "  - $_" }
  }
  if ($brokenRawLinks.Count) {
    Write-Output ""
    Write-Output "Broken raw links:"
    $brokenRawLinks | Format-Table -AutoSize
  }
  if ($schemaIssues.Count) {
    Write-Output ""
    if ($StrictSchema) {
      Write-Output "Schema issues:"
    } else {
      Write-Output "Schema warnings:"
    }
    $schemaIssues | Select-Object -First 80 | Format-Table -AutoSize
    if ($schemaIssues.Count -gt 80) {
      Write-Output "  ... $($schemaIssues.Count - 80) more"
    }
  }
  if ($typeDirectoryIssues.Count) {
    Write-Output ""
    Write-Output "Type/directory issues:"
    $typeDirectoryIssues | Format-Table -AutoSize
  }
  if ($namingIssues.Count) {
    Write-Output ""
    Write-Output "Naming issues:"
    $namingIssues | Format-Table -AutoSize
  }
  exit 1
}

if ($schemaIssues.Count) {
  Write-Output ""
  Write-Output "Schema warnings:"
  $schemaIssues | Select-Object -First 30 | Format-Table -AutoSize
  if ($schemaIssues.Count -gt 30) {
    Write-Output "  ... $($schemaIssues.Count - 30) more"
  }
  Write-Output "Use -StrictSchema to fail on schema warnings."
}

Write-Output "status: ok"
