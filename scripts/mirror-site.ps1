param(
  [string]$BaseUrl = "https://earthbroker.co.za",
  [string]$OutDir = "C:\Users\GadliNet5\mirror-earthbroker"
)

$ErrorActionPreference = "Continue"
$AllUrls = @{}
$Pending = New-Object System.Collections.Queue
$Downloaded = 0

# Key pages to mirror
$SeedPages = @(
  "/",
  "/classifieds/",
  "/digital-magazine/",
  "/about/",
  "/contact/",
  "/advertisers-index/",
  "/featured-business/",
  "/business-directory/"
)

function Get-PageUrls {
  param($Url, $Html)
  $result = @()
  # Extract image URLs
  $imgPattern = 'src="([^"]+\.(jpg|jpeg|png|gif|webp|svg))"'
  $matches = [regex]::Matches($Html, $imgPattern, 'IgnoreCase')
  foreach ($m in $matches) { $result += $m.Groups[1].Value }

  # Extract CSS URLs
  $cssPattern = 'href="([^"]+\.css)"'
  $matches = [regex]::Matches($Html, $cssPattern, 'IgnoreCase')
  foreach ($m in $matches) { $result += $m.Groups[1].Value }

  # Extract JS URLs
  $jsPattern = 'src="([^"]+\.js)"'
  $matches = [regex]::Matches($Html, $jsPattern, 'IgnoreCase')
  foreach ($m in $matches) { $result += $m.Groups[1].Value }

  # Extract internal links (for crawling)
  $linkPattern = 'href="(https://earthbroker\.co\.za[^"]*)"'
  $matches = [regex]::Matches($Html, $linkPattern, 'IgnoreCase')
  foreach ($m in $matches) { $result += $m.Groups[1].Value }

  $linkPattern2 = 'href="(/[^"]+)"'
  $matches = [regex]::Matches($Html, $linkPattern2, 'IgnoreCase')
  foreach ($m in $matches) {
    $v = $m.Groups[1].Value
    if ($v -match '\.(jpg|jpeg|png|gif|webp|svg|css|js|ico|pdf|xml|json|woff2?|ttf|eot)$') { $result += $v }
  }

  return $result | Where-Object { $_ -notmatch '^(mailto:|tel:|javascript:|#|//www\.|//fonts\.|//platform\.)' } | Select-Object -Unique
}

function Save-Url {
  param($Url)
  $uri = if ($Url -match '^https?://') { [Uri]$Url } else { [Uri]"$BaseUrl$Url" }
  $key = $uri.AbsolutePath
  if ($AllUrls.ContainsKey($key)) { return }
  $AllUrls[$key] = $true
  $Pending.Enqueue($uri.AbsoluteUri)
}

# Determine local path for a URL
function Get-LocalPath {
  param($Url)
  $u = [Uri]$Url
  $path = $u.AbsolutePath.TrimStart('/')
  if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
  $full = Join-Path $OutDir $path
  $dir = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force > $null }
  return $full
}

Write-Host "=== EarthBroker Site Mirror ===" -ForegroundColor Cyan
Write-Host "Target: $BaseUrl" -ForegroundColor Yellow
Write-Host "Output: $OutDir" -ForegroundColor Yellow

# Seed the queue
foreach ($page in $SeedPages) { Save-Url $page }

while ($Pending.Count -gt 0 -and $Downloaded -lt 500) {
  $url = $Pending.Dequeue()
  $localPath = Get-LocalPath $url
  if (Test-Path $localPath) { continue }

  Write-Host "[$($Downloaded+1)] Downloading: $url" -ForegroundColor Green
  try {
    $tmpFile = [System.IO.Path]::GetTempFileName()
    $code = (curl.exe -sL -o $tmpFile -w "%{http_code}" --max-time 30 $url 2>&1)
    if ($code -eq 200) {
      $isText = $url -match '\.(html?|css|js|xml|json|svg)$' -or -not ($url -match '\.\w{2,5}$')
      if ($isText -and ((Get-Item $tmpFile).Length -lt 10MB)) {
        $html = Get-Content $tmpFile -Raw -Encoding UTF8
        # Find more URLs to download
        $urls = Get-PageUrls -Url $url -Html $html
        foreach ($u in $urls) {
          if ($u -match '^https?://') { Save-Url $u }
          elseif ($u -match '^/') { Save-Url $u }
        }
        # Also search for inline background images
        $bgPattern = 'url\([''"]?([^''"\)]+\.(jpg|jpeg|png|gif|webp))[''"]?\)'
        $bgMatches = [regex]::Matches($html, $bgPattern, 'IgnoreCase')
        foreach ($m in $bgMatches) {
          $bgUrl = $m.Groups[1].Value
          if ($bgUrl -match '^https?://earthbroker') { Save-Url $bgUrl }
          elseif ($bgUrl -match '^/') { Save-Url $bgUrl }
        }
        # Move to final location
        if ($localPath -match '\.\w{2,5}$') {
          Move-Item $tmpFile $localPath -Force
        } else {
          # HTML page - ensure .html extension
          if (-not ($localPath -match '\.html?$')) { $localPath = "$localPath/index.html" }
          $dir = Split-Path $localPath -Parent
          if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force > $null }
          Move-Item $tmpFile $localPath -Force
        }
      } else {
        # Binary file
        Move-Item $tmpFile $localPath -Force
      }
      $Downloaded++
      Write-Host "  -> $localPath" -ForegroundColor DarkGray
    } else {
      Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
      Write-Host "  FAILED (HTTP $code)" -ForegroundColor Red
    }
  } catch {
    Write-Host "  ERROR: $_" -ForegroundColor Red
  }
}

Write-Host "=== Mirror Complete ===" -ForegroundColor Cyan
Write-Host "Downloaded $Downloaded files to $OutDir" -ForegroundColor Green
