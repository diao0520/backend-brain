<#
.SYNOPSIS
  Backend Brain Phase 4: 环境检查 (PowerShell 版)
.DESCRIPTION
  检查 Git 状态、依赖过期、TODOs、配置文件、大文件。
  输出与 preflight.sh 一致的 JSON schema。
.PARAMETER ProjectPath
  项目路径，默认当前目录
.EXAMPLE
  .\preflight.ps1
  .\preflight.ps1 C:\Projects\my-api
#>
param([string]$ProjectPath = (Get-Location).Path)

$ErrorActionPreference = 'Stop'

# ── 辅助函数 ──
function Invoke-Git {
    param([string]$Arg)
    $out = git $Arg 2>&1 | Out-String
    $global:LASTEXITCODE = 0
    return $out.Trim()
}

# ── 1. Git ──
$gitBranch = ""
$gitDirty = $false
$gitBehind = $false
$gitUntracked = 0

$gitDir = Invoke-Git "rev-parse --git-dir"
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($gitDir)) {
    $gitBranch = Invoke-Git "branch --show-current"
    $porcelain = Invoke-Git "status --porcelain"
    $gitDirty = -not [string]::IsNullOrWhiteSpace($porcelain)

    $null = Invoke-Git "fetch --dry-run" 2>$null
    $behindLog = Invoke-Git "log HEAD..origin/$gitBranch --oneline" 2>$null
    $gitBehind = -not [string]::IsNullOrWhiteSpace($behindLog)

    $untrackedOut = Invoke-Git "ls-files --others --exclude-standard"
    if (-not [string]::IsNullOrWhiteSpace($untrackedOut)) {
        $gitUntracked = ($untrackedOut -split "`n" | Measure-Object).Count
    }
}

# ── 2. Dependencies ──
$depsOutdated = $false
if (Test-Path "$ProjectPath\package.json") {
    $npmOut = npm outdated --json 2>$null
    if ($npmOut -match '{') { $depsOutdated = $true }
}
elseif (Test-Path "$ProjectPath\requirements.txt") {
    $pipOut = pip list --outdated --format=json 2>$null
    if ($pipOut -match '{') { $depsOutdated = $true }
}

# ── 3. TODOs ──
$todoCount = 0
if (Test-Path "$ProjectPath") {
    $todoLines = Select-String -Path "$ProjectPath\**\*.py","$ProjectPath\**\*.ts","$ProjectPath\**\*.js","$ProjectPath\**\*.java","$ProjectPath\**\*.go","$ProjectPath\**\*.rs" -Pattern "TODO|FIXME" -SimpleMatch 2>$null
    if ($todoLines) { $todoCount = ($todoLines | Measure-Object).Count }
}

# ── 4. Config & infra ──
$configFound = $false
foreach ($f in @(".env",".env.local","application.yml","application.properties","application.yaml")) {
    if (Test-Path "$ProjectPath\$f") { $configFound = $true; break }
}

$migration = "none"
if (Test-Path "$ProjectPath\migrations" -or Test-Path "$ProjectPath\alembic" -or
    Test-Path "$ProjectPath\db\migration" -or Test-Path "$ProjectPath\src\main\resources\db\migration") {
    $migration = "detected"
}

$redis = "unknown"
try {
    $redisPing = redis-cli ping 2>$null
    if ($redisPing -match "PONG") { $redis = "true" } else { $redis = "false" }
} catch { $redis = "false" }

# ── 5. Large files ──
$largeFiles = @()
$extensions = @("*.py","*.ts","*.js","*.java","*.go","*.rs")
foreach ($ext in $extensions) {
    Get-ChildItem -Path "$ProjectPath" -Filter $ext -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $lines = (Get-Content $_.FullName | Measure-Object).Count
        if ($lines -gt 500) { $largeFiles += "$($_.Name):$lines" }
    }
}
$largeStr = if ($largeFiles.Count -gt 0) { $largeFiles -join "," } else { "none" }

# ── 输出 JSON ──
$result = @{
    git = @{
        branch     = $gitBranch
        dirty      = $gitDirty
        behind     = $gitBehind
        untracked  = $gitUntracked
    }
    deps = @{
        outdated   = $depsOutdated
    }
    config = @{
        found      = $configFound
        migration  = $migration
        redis      = $redis
    }
    code = @{
        todo_count = $todoCount
        large_files = $largeStr
    }
}

$json = $result | ConvertTo-Json -Compress
Write-Output $json
