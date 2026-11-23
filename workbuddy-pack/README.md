# workbuddy-pack — WorkBuddy 专用技能包

> 本目录是 `../skills/`(Codex/DSH 通用版)的 **WorkBuddy 适配版**:frontmatter 已按 WorkBuddy 规范补齐 `display_name` / `display_name_en` / `description_zh` / `description_en` / `version` / `author` 等必填字段,正文方法内容一致。
> 依据:https://open.workbuddy.cn/docs/skill (官方文档,2026-11 确认)

## 三个技能

| 技能 | 用途 | 对应通用版 |
|---|---|---|
| `common-ops` | 跨工具跨平台排错方法论:四步法、三类误判、安全红线 | `../skills/common-ops` |
| `windows-pwsh-ops` | Windows + PowerShell 5.1 事实 | `../skills/windows-pwsh-ops` |
| `unix-shell-ops` | macOS/Linux 常见坑 | `../skills/unix-shell-ops` |

## 路径 A:WorkBuddy 内对话创建(个人用,最快)

1. 打开 WorkBuddy → 左侧【专家·技能·连接器】→【技能】→ 右上【添加技能】→【创建技能】;
2. 把下列内容发给它:「打开本仓库的 `workbuddy-pack/<技能名>/SKILL.md`,按其中内容创建同名技能,frontmatter 字段保持不变」;
3. 创建后在对话中测试触发(description 里的触发词是唯一依据)。

## 路径 B:开放平台上架(面向所有 WorkBuddy 用户)

1. 入驻 https://open.workbuddy.cn/ 并通过开发者/企业资质认证;
2. 创建「技能」,提交 zip 包。zip 结构必须是:

```
common-ops.zip
└─ common-ops/            ← 顶层必须是有技能名的目录
   └─ SKILL.md
```

3. 打包命令(在 `workbuddy-pack/` 目录内;仓库也预生成了三个 zip 在 `zips/` 下,可直接下载使用):

```powershell
# Windows
Compress-Archive -Path .\common-ops -DestinationPath .\common-ops.zip
Compress-Archive -Path .\windows-pwsh-ops -DestinationPath .\windows-pwsh-ops.zip
Compress-Archive -Path .\unix-shell-ops -DestinationPath .\unix-shell-ops.zip
```
```bash
# macOS / Linux
zip -r common-ops.zip common-ops
zip -r windows-pwsh-ops.zip windows-pwsh-ops
zip -r unix-shell-ops.zip unix-shell-ops
```

4. 平台解析失败排查:对照官方「技能基础结构 / 子资源目录说明」(frontmatter 字段是否齐全、SKILL.md 是否在顶层目录内)。

## 约定

- `description` 写清用途**和触发词**——这是 WorkBuddy 调用技能的唯一依据;
- 修改正文后请递增 `version`,市场侧才会识别更新;
- 所有结论保持 `[已验证]` / `[观察]` 标记,不写未经复现的推断;
- 本目录内容不参与 Codex/DSH 的本地安装(`install.ps1` / `install.sh` 只处理 `../skills/`)。

## 已知限制

- 上架需腾讯平台审核,周期与规则以开放平台为准;
- 技能市场入口见 WorkBuddy 内【技能市场】(外部宣传页 https://skillhub.cn/);
- 若官方后续支持本地目录式技能,本包将自动切换为「复制目录」方式,届时以官方文档为准。
