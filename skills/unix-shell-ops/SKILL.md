---
name: unix-shell-ops
description: 在 macOS/Linux 上执行命令、写 shell 脚本、配置环境之前先加载:shell 差异(zsh 与 bash 的数组/行为不同、dash 不支持数组)、PATH 与解释器定位、PYTHONPATH 与仓库根导入、管道与权限,先探测再分支。适合「脚本行为不一致 / PATH 找不到命令 / Python 导入失败 / 权限被拒」这类问题。
---

# Unix Shell Ops

> 本文件只放**跨机成立的机制事实**(标 `[机制]`:shell/系统行为,任何同环境机器成立,依据可查各 shell 文档)。**本机特殊现象不在本文件**——按 common-ops 维护协议写本机动态层,并以它为准。

## 动手前先探测(一行)

- `echo $0` / `command -v bash` 确认当前 shell:macOS 默认 zsh;Debian/Ubuntu 的 `/bin/sh` 是 dash;
- 写脚本一律以 bash 为目标,显式 `bash script.sh` 运行,避免 shebang 依赖猜测。

## 一、shell 差异 [机制]

- **zsh 数组下标从 1 开始,bash 从 0 开始**;同一脚本在两个 shell 下行为可能不同;
- `shopt`(bash)与 `setopt`(zsh)不通用,别混用;
- `/bin/sh` 在 Debian/Ubuntu 上是 dash,不支持部分 bash 特性(如 `$'...'` 转义、数组);
- 结论:目标平台明确时,用 `#!/usr/bin/env bash` + `bash xxx.sh` 运行。

## 二、PATH 与解释器定位 [机制]

- 先 `command -v <cmd>` 确认实际解析到哪个可执行文件,再怀疑代码;
- PATH 中前面目录优先;改了 PATH 后要 `export`,否则子进程/新 shell 看不到;
- 不要 `source ~/.zshrc` 之类「复用用户配置」——应读取该文件确认内容。

## 三、PYTHONPATH 与模块导入 [机制]

- 从**仓库根目录**运行 `python` 才能 `import` 仓库内的包;在子目录运行会 `ModuleNotFoundError`;
- 临时修:`PYTHONPATH=. python script.py`(或 `python -m pkg.script`);
- 不同 Python 环境(venv/conda/系统)的解释器、包版本可能不同——先 `command -v python` 确认。

## 四、管道与退出码 [机制]

- 管道中一个命令失败,整体退出码默认取最后一个命令;需要严格时用 `set -o pipefail`(bash)/ `setopt pipefail`(zsh);
- `set -e` 并非万能:失败可能被 `|| true`、条件上下文吞掉,关键步骤显式检查退出码。

## 五、权限与文件操作 [机制]

- 脚本无执行权限:`bash script.sh` 直接运行即可,别顺手 `chmod 777`;
- 需要授权时用 `chmod +x`(仅本人)或 `chmod u+x`,不做全局放开;
- 文件名含空格/通配符:加引号;批量处理用 `find ... -print0 | xargs -0`,别在 for 循环里裸用空格分隔。

## 六、可逆性与红线

- 删除/覆盖前先确认,`rm -rf` 只用于用户明确指定的路径 [机制];
- 不写密钥/token 进脚本;不执行来源不明的 `curl ... | sh` [机制]。

## 七、本机动态层

- 本机实测/特殊现象按 common-ops 维护协议写入 local-ops,并以它为准;
- 跨机机制事实的补充/更正:需 ≥2 台不同机器复现 + 用户确认,才可改进本文件。
