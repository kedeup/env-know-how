<#
install.ps1 — env-know-how 探测式安装器(Windows PowerShell 5.1+)

用法:
  powershell -ExecutionPolicy Bypass -File .\install.ps1          # 安全默认:已存在的同名技能跳过
  powershell -ExecutionPolicy Bypass -File .\install.ps1 -Force   # 覆盖同名技能

安全声明:
  - 只写当前用户目录(复制技能 + 视情况追加指针行),不删除用户的现有文件;
  - 不需要管理员权限,不修改系统配置。
#>
param(
    [switch]$Force
)
$ErrorActionPreference = "Stop"

# ---- 定位 ----
$Root = $PSScriptRoot                       # 仓库根(本脚本所在目录)
$SkillsSrc = Join-Path $Root "skills"
$SkillNames = @("common-ops", "windows-pwsh-ops", "unix-shell-ops")
$PointerMarker = "# env-know-how"
$PointerLine = "> 环境知识包:技能位于本机对应 skills 目录(common-ops / windows-pwsh-ops / unix-shell-ops),执行命令/文件操作前优先加载。"

# ---- 本机动态层种子(local-ops:用户数据,只创建,永不覆盖)----
$LocalOpsSeed = @'
---
name: local-ops
description: 本机实测经验档案(按维护协议自动维护)。执行命令、读写文件、排查报错之前先读本文件:记载这台机器上复现过的环境坑与解法,带 [观察]/[已验证] 标签。适合「这台机器之前出过什么问题 / 上次怎么解决的 / 本机特殊情况」。
---

# 本机经验档案(local-ops)

> 维护协议见 common-ops「本机知识维护协议」:append-only、默认 [观察]、≥2 次不同会话复现且用户确认才 [已验证];疑似敏感信息(密钥/token/内网地址)一律写「已省略」;不覆盖、不删除旧条目。本文件初始近乎为空,随本机会话增长。
> 优先级:本文件 > 平台技能,以本机实测为准。

## 已沉淀条目

(暂无)
'@

if (-not (Test-Path $SkillsSrc)) {
    throw "未找到技能源目录:$SkillsSrc 。请从仓库根(有 install.ps1 的目录)运行本脚本。"
}

# ---- 探测已安装的 agent(按用户目录是否存在)----
$targets = @()

if (Test-Path "$env:USERPROFILE\.codex") {
    $targets += @{ Name = "Codex"; SkillsDir = "$env:USERPROFILE\.agents\skills"; Pointer = "$env:USERPROFILE\.codex\AGENTS.md" }
}
if (Test-Path "$env:USERPROFILE\.claude") {
    $targets += @{ Name = "Claude Code"; SkillsDir = "$env:USERPROFILE\.claude\skills"; Pointer = "$env:USERPROFILE\.claude\CLAUDE.md" }
}
if (Test-Path "$env:USERPROFILE\.dsh") {
    $targets += @{ Name = "DeepSeek Harness"; SkillsDir = "$env:USERPROFILE\.dsh\skills"; Pointer = $null }
}
if (Test-Path "$env:USERPROFILE\.workbuddy") {
    Write-Warning "检测到 ~\.workbuddy:WorkBuddy 技能经【技能市场】安装 /【创建技能】生成,无本地技能目录,本安装器不处理。如需上架,见 INSTALL.md「WorkBuddy 专用说明」。"
}

if ($targets.Count -eq 0) {
    Write-Host "未检测到受支持的 agent 用户目录(Codex / Claude Code / DeepSeek Harness)。"
    Write-Host "已知工具但目录不在这几个:请按 INSTALL.md 的「常见问题」提供信息。"
    exit 0
}

# ---- 指针追加:返回 0=已写过,1=本次追加,2=文件不存在 ----
function Test-Or-AppendPointer($file, $text) {
    if (-not (Test-Path $file)) { return 2 }
    $content = [System.IO.File]::ReadAllText($file)
    if ($content.Contains($PointerMarker)) { return 0 }
    $append = "`r`n$PointerMarker`r`n$text`r`n"
    [System.IO.File]::AppendAllText($file, $append)
    return 1
}

# ---- 复制技能 ----
$installed = 0; $skipped = 0; $pointerDone = 0; $pointerSkip = 0

foreach ($t in $targets) {
    if (-not (Test-Path $t.SkillsDir)) {
        New-Item -ItemType Directory -Path $t.SkillsDir -Force | Out-Null
    }
    foreach ($name in $SkillNames) {
        $src = Join-Path $SkillsSrc $name
        $dst = Join-Path $t.SkillsDir $name
        if (Test-Path $dst) {
            if ($Force) {
                Remove-Item $dst -Recurse -Force
                Copy-Item $src $dst -Recurse -Force
                Write-Host "[覆盖] $($t.Name): $name"
                $installed++
            } else {
                Write-Host "[跳过] $($t.Name): $name 已存在(如需覆盖请加 -Force)"
                $skipped++
            }
        } else {
            Copy-Item $src $dst -Recurse -Force
            Write-Host "[安装] $($t.Name): $name"
            $installed++
        }
    }
    if ($t.Pointer) {
        switch (Test-Or-AppendPointer $t.Pointer $PointerLine) {
            0 { Write-Host "[指针] $($t.Name): $($t.Pointer) 已含 env-know-how 标记,跳过"; $pointerSkip++ }
            1 { Write-Host "[指针] $($t.Name): 已追加到 $($t.Pointer)"; $pointerDone++ }
            2 { Write-Host "[指针] $($t.Name): 未找到 $($t.Pointer),跳过(不创建新文件)"; $pointerSkip++ }
        }
    }
    # ---- 本机动态层 local-ops(用户数据:只创建,永不覆盖)----
    $loDir = Join-Path $t.SkillsDir "local-ops"
    $loFile = Join-Path $loDir "SKILL.md"
    if (Test-Path $loFile) {
        Write-Host "[动态层] $($t.Name): local-ops 已存在,跳过(用户数据,不覆盖)"
    } else {
        New-Item -ItemType Directory -Path $loDir -Force | Out-Null
        [System.IO.File]::WriteAllText($loFile, $LocalOpsSeed, (New-Object System.Text.UTF8Encoding($true)))
        Write-Host "[动态层] $($t.Name): 已创建 local-ops(本机经验档案,随会话增长)"
    }
}

# ---- 汇总 ----
Write-Host ""
Write-Host "完成:安装/覆盖 $installed 个技能,跳过 $skipped 个,追加指针 $pointerDone 个。"
Write-Host "提示:打开对应 agent 的【新】会话并询问技能列表,确认 common-ops / windows-pwsh-ops / unix-shell-ops 已出现。"
