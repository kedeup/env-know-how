---
name: windows-pwsh-ops
description: 在 Windows 机器上执行命令、写 PowerShell、处理文件路径之前先加载:PowerShell 5.1 与 7+ 的机制差异(ProcessStartInfo.ArgumentList、无 BOM 编码行为、命令长度、执行策略),先探测版本再分支。适合「PowerShell 又报错 / 输出中文乱码 / 命令超长 / 进程起不来」这类问题。
---

# Windows + PowerShell Ops

> 本文件只放**跨机成立的机制事实**(标 `[机制]`:系统/运行时行为,任何同环境机器成立,依据可查 PowerShell/.NET/Windows 文档)。**这台机器的特殊现象不在本文件**——按 common-ops 维护协议写本机动态层 `~/.<工具>/skills/local-ops/SKILL.md`,并以它为准。

## 动手前先探测(一行)

- 版本:`powershell -NoProfile -Command $PSVersionTable.PSVersion.ToString()` → 5.1 与 7+ 行为不同,下文按 5.1 为默认;
- 代码页:`chcp` 查看(简体中文 Windows 默认 936/GBK,其他区域不同)。

## 一、.NET API 版本差异 [机制]

- `ProcessStartInfo.ArgumentList` 只存在于 .NET Core / PowerShell 7+;**5.1(.NET Framework)没有**;
- 5.1 用 `$psi.Arguments` 字符串,含空格/引号的值要手动加引号;
- 优先 `Start-Process -ArgumentList @(...)` 传参数数组,避免手工拼字符串。

## 二、编码与乱码 [机制]

- 「乱码」多半是**显示编码问题**(GBK 控制台 vs UTF-8 内容),不是文件损坏——先用读取工具按 UTF-8 重读确认;
- **5.1 的 `-Encoding UTF8` 写入带 BOM;7+ 默认无 BOM**;要指定用 `[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))`;
- **含中文的 `.ps1` 必须存为 UTF-8 带 BOM**:5.1 读无 BOM 文件按 ANSI(GBK)解码 → 中文乱码 → 解析器报「意外的标记」;7+ 按 UTF-8 读,正常。稳妥做法:脚本一律存带 BOM 的 UTF-8(5.1 兼容);
- 写入后校验:用读取工具重新打开确认内容可读,再继续。

## 三、命令长度 [机制]

- cmd.exe 单条命令上限约 8191 字符,超长会莫名截断/报错;
- 复杂逻辑写成 `.ps1` 文件执行;参数很多的调用保持 < 7000 字符,给引号转义留余量。

## 四、启动进程

- GUI 程序用 `Start-Process -FilePath <完整路径>`;等待结束加 `-Wait` 或 `$p.WaitForExit()` [机制];
- Electron/Node 类 CLI 可用 `ELECTRON_RUN_AS_NODE=1` 以 node 模式运行 [机制];
- 某些 Electron/Chromium 类程序会输出 crashpad 报错日志——是噪声,以 `$LASTEXITCODE`/ExitCode 为准 [观察](遇到过,非全平台通用)。

## 五、语法与路径 [机制]

- `-not`/`-and`/`-or` 优先级和括号行为与 C 系语言不同,混用时加括号;
- 用户目录用 `$env:USERPROFILE`;
- 中文/空格路径:参数加引号;脚本内用 `Join-Path` 拼路径,别用字符串拼接;
- 单引号不展开变量、双引号展开——拼路径/命令时注意区分。

## 六、执行策略(安全)[机制]

- 遇「禁止运行脚本」:`powershell -ExecutionPolicy Bypass -File xxx.ps1` 参数运行,**不要**改系统执行策略;
- 只做可逆操作:不改注册表、不改系统级配置、不要求提权。

## 七、本机动态层

- 本机实测/特殊现象(如某版本工具多出怪报错)按 common-ops 维护协议写入 local-ops,并以它为准;
- 跨机机制事实的补充/更正:需 ≥2 台不同机器复现 + 用户确认,才可改进本文件。
