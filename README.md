# Agent 环境知识包 (env-know-how)

> 给任意 AI 编码工具用的「本机操作常识」**种子 + 自学习协议**。一次安装后,Codex / Claude Code / DeepSeek Harness 等都会在会话开始时自动加载排错方法论与跨机机制事实,并把你在这台机器上踩过的坑沉淀进**本机动态层**,越用越贴合你的机器。
> 仓库:https://github.com/kedeup/env-know-how (Public)
> English: [README.en.md](README.en.md)

## 它是什么

这个包不假装自己是「普适事实库」——别人机器是什么版本、什么编码,我们不知道,也不猜。它由两层组成:

- **静态层(本仓库)**:跨工具/跨平台通用的排错方法论与维护协议,加上少数**跨机成立**的机制事实(如 PowerShell 5.1 与 7+ 的行为差异、shell 数组下标、命令长度上限),每条都标 `[机制]` / `[已验证]` / `[观察]`;
- **本机动态层(安装后生成,不入仓库)**:`~/.<工具>/skills/local-ops/SKILL.md`——你的 agent 按协议把在这台机器上真实复现过的问题与解法追加进去(默认 `[观察]`,≥2 次复现且你确认后才升 `[已验证]`)。

**结果**:不同机器的包会长成不同形状——你的 GBK 乱码、他的 pwsh 7 差异,都只记在自己的动态层里,不互相污染。

## 支持矩阵

| Agent | 用户级技能落点 | 状态 |
|---|---|---|
| Codex (CLI) | `~/.agents/skills/`(Codex 个人技能共享根)+ `~/.codex/AGENTS.md` 指针 | ✅ 实测(二进制含 `.agents/skills`) |
| DeepSeek Harness | `~/.dsh/skills/`(rank 400,DSH 专属) | ✅ 实测(官方 rank 表) |
| Claude Code | `~/.claude/skills/` + `~/.claude/CLAUDE.md` 指针 | 🟡 路径与官方约定一致,待会话内加载确认 |
| WorkBuddy(腾讯) | 无本地文件技能目录;经【技能市场】安装 /【创建技能】生成 | ✅ 官方文档确认([open.workbuddy.cn/docs/skill](https://open.workbuddy.cn/docs/skill)) |

## 快速开始

1. 下载/克隆本仓库:`git clone https://github.com/kedeup/env-know-how.git`;
2. 运行安装器(Windows: `powershell -ExecutionPolicy Bypass -File install.ps1`;macOS/Linux: `bash install.sh`);安装器同时创建本机动态层 local-ops;
3. 任意新会话发一句:「查看我的技能/指令文件,环境知识包应该已就位」验证。

或者更简单——**把这句话发给任意 agent**:
> 请阅读本仓库的 INSTALL.md,按步骤为我安装。

WorkBuddy 用户不同:它没有本地技能目录,请打开 [workbuddy-pack/](workbuddy-pack/README.md) 按其说明通过市场/对话创建。

## 目录结构

```
env-know-how/
├─ README.md / README.en.md    双语说明
├─ INSTALL.md                  人/agent 通用安装手册(唯一权威入口)
├─ AGENTS.md                   项目级指令:任何 agent 进入本仓库即生效
├─ PUBLISH.md                  GitHub 发布与更新指南
├─ install.ps1 / install.sh    探测式安装器(创建静态层 + 本机动态层)
├─ skills/                     静态层:方法论 / 机制事实(本地目录安装)
│  ├─ common-ops/              方法论 + 本机知识维护协议
│  ├─ windows-pwsh-ops/        Windows + PowerShell 机制事实
│  └─ unix-shell-ops/          macOS/Linux 机制事实
└─ workbuddy-pack/             WorkBuddy 专用适配(市场/对话创建)

安装后生成(不在仓库):
  ~/.<工具>/skills/local-ops/SKILL.md   本机动态层,随会话增长
```

## 内容原则

- **三档标签**:`[机制]`(系统/运行时行为,跨机成立,依据可查官方文档)、`[已验证]`(本机复现且结论确定)、`[观察]`(出现过但未确证);
- **本机事实不进仓库**:任何只在一台机器上成立的东西,写进那台机器的 local-ops;
- **工具差异不止落盘位置**:WorkBuddy 的 SKILL.md frontmatter 还要求 `display_name`/`description_zh` 等字段,且无本地技能目录——本安装器不覆盖它,见 workbuddy-pack;
- **安全红线**:不含任何密钥/token/内网地址;安装器只写用户目录,不需要管理员权限;
- **维护协议**:追加式、不覆盖旧条目、默认 [观察]、≥2 次复现且用户确认才 [已验证],详见 common-ops。

## 维护与贡献

- 新增**机制事实**必须来自真实复现 + 可引用依据;本机经验请沉淀到 local-ops,不要提交进仓库;
- 修改平台技能正文 = 修改「跨机成立」的知识,需 ≥2 台不同机器复现 + 用户确认;
- 欢迎 PR:方法论进 common-ops,机制事实进对应平台技能;工具专属内容(如 DSH 的 asar 读取)不要混入通用层。

## 许可

- 本仓库整体采用 [MIT License](LICENSE);
- 使用本包内容请保留出处;修改后可自由分发,注明基于本仓库改进即可。
