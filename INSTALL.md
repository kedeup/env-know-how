# 安装手册 (INSTALL.md)

> 本文件同时给人和 AI 读。任何 agent 只要读到它,就能独立完成安装。
> 安装只写你自己的用户目录(`~/.codex`、`~/.claude`、`~/.dsh`、`~/.agents`),不需要管理员权限,不含任何密钥。

## 这个包装什么

三个技能,按需自动加载:

| 技能 | 用途 |
|---|---|
| `common-ops` | 排错方法论:报错先分类再动手、乱码/权限/子进程三类误判排除、安全红线 |
| `windows-pwsh-ops` | Windows + PowerShell 5.1 事实:ArgumentList 缺失、GBK 乱码、命令长度、转义 |
| `unix-shell-ops` | macOS/Linux 常见坑:shell 差异、PATH、PYTHONPATH |
| `local-ops`(本机动态层,安装时自动创建,不进仓库) | 这台机器上实测经验档案,agent 按 common-ops 维护协议自动追加,越用越贴合 |

## 方法 A(推荐):让 agent 自己装

把下面这句话发给你的 agent(Codex / Claude / DSH / WorkBuddy 均可):

> 请阅读 `https://raw.githubusercontent.com/kedeup/env-know-how/main/INSTALL.md`,按其中的步骤为我安装环境知识包。如果我的工具不在它认识的列表里,先告诉我我用的工具和它的配置目录,再继续。若 `raw.githubusercontent.com` 无法访问,退而阅读 `https://github.com/kedeup/env-know-how/blob/main/INSTALL.md`。

agent 会:读本文件 → 优先运行安装器 → 失败走手动路径 → 验证 → 汇报。

**无需 git**:本流程不 clone 仓库。若本机没有 git、或 clone 失败,**不要要求用户安装 git**;改为用 `https://raw.githubusercontent.com/kedeup/env-know-how/main/<文件路径>` 逐个拉取 `install.ps1`(Windows)/`install.sh`(macOS 与 Linux)及各 `skills/<技能名>/SKILL.md`,写入临时目录后执行,或直接按「方法 C」逐文件落盘。

## 方法 B:手动运行安装器

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**macOS / Linux:**
```bash
bash install.sh
```

安装器自动探测已安装的 agent,并按表格落盘;**不会覆盖你已有的同名技能**(除非加 `-Force`)。

## 方法 C:手动复制(不想跑脚本时)

| Agent | 技能复制到 | 指针文件追加一行 |
|---|---|---|
| Codex | `~/.agents/skills/` | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/skills/` | `~/.claude/CLAUDE.md` |
| DeepSeek Harness | `~/.dsh/skills/` | 无需 |
| WorkBuddy | 无(走市场安装) | 见「WorkBuddy 专用说明」 |

指针行内容(建议原文):
`> 环境知识包:技能位于 <上面复制的目录>,本机执行命令/文件操作前优先加载。`

> 本机动态层 `local-ops` 由安装器自动创建,无需手动操作;走手动复制时,agent 首次需要沉淀经验时按 common-ops 的维护协议创建即可。

## 验证是否装好

- **Codex**:新会话里问「列出你的个人技能」,应出现 common-ops / windows-pwsh-ops / unix-shell-ops;
- **Claude Code**:同问,或检查 `~/.claude/skills/` 下目录存在;
- **DSH**:新会话的技能目录应出现三个技能(无需重启);
- **local-ops**:各工具技能目录下应出现 `local-ops/SKILL.md`(初始近乎为空属正常,内容随会话增长);
- 或直接看文件:`ls ~/.agents/skills ~/.claude/skills ~/.dsh/skills`(存在的部分)。

## WorkBuddy 专用说明(官方文档已确认)

WorkBuddy = 腾讯桌面 AI 工作台。它的技能**不读本地文件目录**,与 Codex/DSH 的「复制到 skills 目录」完全不同:

- **安装方式**:用户在【专家·技能·连接器】→【技能】→【技能市场】点右上角 `+` 安装;或点【添加技能】→【创建技能】,在对话里补全提示词让 AI 生成;
- **上架方式**:入驻开放平台后,把 `<技能名>/SKILL.md`(+references/scripts/templates)打成 zip 提交,平台解析后发布到市场;
- **frontmatter 必填项**(比 Codex/DSH 多):`name`、`display_name`、`display_name_en`、`description`(写清触发词)、`description_zh`、`description_en`、`version`、`author`;可选 `allowed-tools`(工具白名单)、`examples_zh/en`;正文用 `@references/xxx.md` 引用参考资料,scripts 由 Bash 工具执行;
- **结论**:本安装器不会(也无法)把技能复制进 WorkBuddy——它没有本地技能目录;检测到 `~/.workbuddy` 只提示、不动作;
- **本仓库自带适配包**:`workbuddy-pack/` 下三个 SKILL.md 已按上述规范改写(补齐 `display_name`/`description_zh`/`version`/`author` 等必填字段),打包与上架步骤见 [workbuddy-pack/README.md](workbuddy-pack/README.md);
- **WorkBuddy 内的一句话用法**:「打开本仓库,读 `workbuddy-pack/<技能名>/SKILL.md`,按 WorkBuddy 规范在【创建技能】里为我创建同名技能。」(内容引用: https://open.workbuddy.cn/docs/skill )

## 常见问题

**Q:提示「不认识的工具」**
不要猜。让用户提供:① 工具名;② 它的用户配置目录(一般在 `~/.<工具名>/`);③ 若它支持 AGENTS.md 约定,复制到项目根即可生效。把信息补进 install.ps1/sh 的探测表再重跑。

**Q:我是 WorkBuddy 用户,怎么装?**
看「WorkBuddy 专用说明」——市场安装/创建技能,不走本地文件安装器。

**Q:安装器说「目标已存在,已跳过」**
安全默认,避免覆盖用户已有技能。确认后加 `-Force` 重跑(会覆盖同名技能)。

**Q:指针文件不存在(如 `~/.codex/AGENTS.md`)**
安装器会创建空文件?不会——它只追加到**已存在**的指针文件,避免制造工具不认的目录。若你的工具要求该文件,请让 agent 按「方法 A」处理。

**Q:Windows 上提示「禁止运行脚本」**
用 `-ExecutionPolicy Bypass` 参数即可(见方法 B);不要改系统执行策略。

## 写给你的 agent(本文件对 agent 的硬规则)

1. 优先执行安装器,失败再走手动;
2. **不要删除用户任何现有文件**;重复安装保持幂等(存在即跳过);
3. 遇到未知工具,**必须停下询问**,不要猜测目录;
4. 安装完成后用「验证」一节确认,并汇报每步结果。
