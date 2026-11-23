---
name: windows-pwsh-ops
display_name: Windows PowerShell 操作指南
display_name_en: Windows PowerShell Ops
description: 在 Windows 机器上执行命令、写 PowerShell、处理文件路径之前使用:PowerShell 5.1 与 7+ 的 .NET API 差异(如 ProcessStartInfo.ArgumentList 不存在)、GBK 控制台输出与 UTF-8 文件(含 BOM 规则)、命令长度上限、执行策略与启动进程。触发词:PowerShell 又报错、输出中文乱码、命令超长、进程起不来、脚本中文乱码。
description_zh: Windows 平台事实:PS 5.1 兼容写法、编码与 BOM、命令长度、执行策略、进程启动。
description_en: Windows facts: PowerShell 5.1 compatibility, encoding and BOM, command length limits, execution policy, process launch.
version: 0.1.0
author: kedeup
examples_zh:
- "PowerShell 5.1 没有 ArgumentList,怎么办?"
- "脚本里的中文全变乱码了"
- "命令太长,一执行就没了"
- "启动一个 GUI 程序怎么等它结束?"
examples_en:
- "PowerShell 5.1 has no ArgumentList, what now?"
- "Chinese text in my script is all garbled"
- "My command is too long and gets truncated"
- "How do I launch a GUI program and wait for it?"
---

# Windows + PowerShell Ops

> Windows 平台事实。执行环境假设为 Windows PowerShell 5.1(系统自带, .NET Framework)与 PowerShell 7+(可选, .NET 8+)。标注差异处按 5.1 为准,因为它默认存在。

## 何时使用

- 在 Windows 上跑任何命令、写 `*.ps1`、读/写带中文的文件、启动进程之前。

## 一、.NET API 版本差异 [已验证]

- **`ProcessStartInfo.ArgumentList` 只存在 .NET Core / PowerShell 7+**;PS 5.1(.NET Framework)调用它报 `InvokeMethodOnNull` 之类错误;
- 5.1 用 `$psi.Arguments` 字符串,参数要**手动加引号**(含空格/引号的值要转义);
- 优先用 `Start-Process -ArgumentList @(...)` 传递参数数组,避免手工拼字符串。

## 二、编码与乱码 [已验证]

- 控制台默认代码页常为 GBK(936);UTF-8 内容打印出来会「乱码」——**是显示问题,不是文件损坏**;
- 写 UTF-8 文件:`-Encoding UTF8`(PowerShell 5.1 会带 BOM,大多数场景可使用);要无 BOM 用 `[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))`;
- 读文件用读取工具(按 UTF-8)或 `Get-Content -Encoding UTF8`,不要用默认编码猜测;
- **含中文的 `.ps1` 必须存为 UTF-8 带 BOM**:PS 5.1 读取无 BOM 文件时按 ANSI(GBK)解码,中文字符串会变乱码,解析器直接报「意外的标记」类错误——先看是不是 BOM 问题,而不是改代码;
- 写入后校验:用读取工具重新打开确认内容可读,再继续。

## 三、命令长度 [已验证]

- cmd.exe 单条命令上限约 8191 字符;超长命令会莫名截断/报错;
- 复杂逻辑写成 `.ps1` 文件执行,而不是一条巨型命令行;
- 参数很多的调用保持 < 7000 字符,给引号转义留余量。

## 四、启动进程

- GUI 程序用 `Start-Process -FilePath <完整路径>`;需要等待结束加 `-Wait` 或 `$p.WaitForExit()`;
- Electron/Node 类 CLI 可以用 `ELECTRON_RUN_AS_NODE=1` 环境变量以 node 模式运行;
- 某些程序输出到终端的日志(如 crashpad 报错)是无害噪声,以 `$LASTEXITCODE` / ExitCode 为准。

## 五、PowerShell 语法与路径 [已验证]

- `-not`/`-and`/`-or` 优先级和括号行为与 C 系语言不同,混用时加括号;
- 用户目录用 `$env:USERPROFILE`(环境变量名,与 `$HOME` 自动变量不同);
- 中文/空格路径:参数加引号;脚本内用 `Join-Path` 拼路径,别用字符串拼接;
- 单引号字符串不展开变量,双引号会展开——拼路径/命令时注意区分。

## 六、执行策略(安全)

- 遇「禁止运行脚本」:用 `powershell -ExecutionPolicy Bypass -File xxx.ps1` 参数运行,**不要**改系统执行策略;
- 遵循「只做可逆操作」:不改注册表、不改系统级配置,不要求提权。
