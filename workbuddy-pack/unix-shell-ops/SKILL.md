---
name: unix-shell-ops
display_name: Unix Shell 操作指南
display_name_en: Unix Shell Ops
description: 在 macOS/Linux 上执行命令、写 shell 脚本、配置环境之前使用:shell 差异(zsh 与 bash 的数组下标/行为不同)、PATH 与解释器定位、PYTHONPATH 与仓库根导入、管道与权限。触发词:脚本行为不一致、PATH 找不到命令、Python 导入失败、权限被拒、管道结果不对。
description_zh: macOS/Linux 常见坑:shell 差异、PATH、PYTHONPATH、管道退出码、权限与批量处理。
description_en: macOS/Linux gotchas: shell differences, PATH, PYTHONPATH, pipeline exit codes, permissions, batch processing.
version: 0.1.0
author: kedeup
examples_zh:
- "同一脚本在 zsh 和 bash 里结果不一样"
- "明明装了 python,却 import 不到包"
- "命令找不到,但路径是对的"
- "批量处理带空格的文件名炸了"
examples_en:
- "Same script behaves differently in zsh and bash"
- "Python is installed but my package won't import"
- "Command not found though the path is right"
- "Batch processing of filenames with spaces exploded"
---

# Unix Shell Ops

> macOS(默认 zsh)与 Linux(常见 bash,dash 作 /bin/sh)平台事实。写脚本一律以 `bash` 为目标,显式 `bash script.sh` 运行,避免 shebang 依赖猜测。

## 何时使用

- 在 macOS/Linux 上执行命令、写 shell、配 PATH/PYTHONPATH、排查导入失败之前。

## 一、shell 差异 [观察]

- **zsh 数组下标从 1 开始,bash 从 0 开始**;同一脚本在两个 shell 下行为可能不同;
- zsh 的 `setopt`/通配行为与 bash 不同,别混用 `shopt`(bash)与 `setopt`(zsh);
- `/bin/sh` 在 Debian/Ubuntu 上是 dash,不支持部分 bash 特性(如 `$'...'` 转义、数组);
- 结论:目标平台明确时,用 `#!/usr/bin/env bash` + `bash xxx.sh` 运行。

## 二、PATH 与解释器定位 [已验证]

- 先用 `command -v <cmd>` 确认实际解析到哪个可执行文件,再怀疑代码;
- PATH 中前面目录优先;改了 PATH 后要 `export`,否则子进程/新 shell 看不到;
- 不要在脚本里 `source ~/.zshrc` 之类去「复用用户配置」——应读取该文件确认内容。

## 三、PYTHONPATH 与模块导入 [已验证]

- 从**仓库根目录**运行 `python` 才能 `import` 仓库内的包;在子目录运行会 `ModuleNotFoundError`;
- 临时修:`PYTHONPATH=. python script.py`(或 `python -m pkg.script`);
- 不同 Python 环境(venv/conda/系统)的解释器、包版本可能不同——先 `command -v python` 确认。

## 四、管道与退出码 [已验证]

- 管道中一个命令失败,整体退出码默认取最后一个命令——需要严格时用 `set -o pipefail`(bash)/ `setopt pipefail`(zsh);
- `set -e` 并非万能:失败可能被 `|| true`、条件上下文吞掉,关键步骤显式检查退出码。

## 五、权限与文件操作 [已验证]

- 脚本无执行权限:`bash script.sh` 直接运行即可,别顺手 `chmod 777`;
- 需要授权时用 `chmod +x`(仅本人)或 `chmod u+x`,不做全局放开;
- 文件名含空格/通配符:加引号;批量处理用 `find ... -print0 | xargs -0`,别在 for 循环里裸用空格分隔。

## 六、可逆性与红线

- 删除/覆盖前先确认,`rm -rf` 只用于用户明确指定的路径;
- 不写密钥/token 进脚本;不执行来源不明的 `curl ... | sh`。
