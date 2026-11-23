#!/bin/sh
# install.sh — env-know-how 探测式安装器(POSIX sh,macOS / Linux)
#
# 用法:
#   bash install.sh           # 安全默认:已存在的同名技能跳过
#   bash install.sh --force   # 覆盖同名技能
#
# 安全声明:
#   - 只写当前用户 $HOME 目录(复制技能 + 视情况追加指针行),不删除用户现有文件;
#   - 不需要 sudo,不修改系统配置。

set -u

FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force|-f) FORCE=1 ;;
    esac
done

ROOT="$(CDPATH= cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$ROOT/skills"
SKILL_NAMES="common-ops windows-pwsh-ops unix-shell-ops"
POINTER_MARKER="# env-know-how"
POINTER_LINE="> 环境知识包:技能位于本机对应 skills 目录(common-ops / windows-pwsh-ops / unix-shell-ops),执行命令/文件操作前优先加载。"

installed=0
skipped=0
pointer_done=0
pointer_skip=0

# 本机动态层种子(local-ops:用户数据,只创建,永不覆盖)
create_local_ops() {
    skills_dir="$1"
    dir="$skills_dir/local-ops"
    file="$dir/SKILL.md"
    if [ -f "$file" ]; then
        echo "[动态层] 已存在 local-ops,跳过(用户数据,不覆盖)"
        return 0
    fi
    mkdir -p "$dir"
    cat > "$file" <<'EOF'
---
name: local-ops
description: 本机实测经验档案(按维护协议自动维护)。执行命令、读写文件、排查报错之前先读本文件:记载这台机器上复现过的环境坑与解法,带 [观察]/[已验证] 标签。适合「这台机器之前出过什么问题 / 上次怎么解决的 / 本机特殊情况」。
---

# 本机经验档案(local-ops)

> 维护协议见 common-ops「本机知识维护协议」:append-only、默认 [观察]、≥2 次不同会话复现且用户确认才 [已验证];疑似敏感信息(密钥/token/内网地址)一律写「已省略」;不覆盖、不删除旧条目。本文件初始近乎为空,随本机会话增长。
> 优先级:本文件 > 平台技能,以本机实测为准。

## 已沉淀条目

(暂无)
EOF
    echo "[动态层] 已创建 local-ops(本机经验档案,随会话增长)"
}

if [ ! -d "$SKILLS_SRC" ]; then
    echo "错误:未找到技能源目录 $SKILLS_SRC 。请从仓库根(有 install.sh 的目录)运行本脚本。" >&2
    exit 1
fi

# 指针追加:退出码 0=已写过,1=本次追加,2=文件不存在
append_pointer() {
    file="$1"; text="$2"
    if [ ! -f "$file" ]; then return 2; fi
    if grep -qF "$POINTER_MARKER" "$file"; then return 0; fi
    printf '\n%s\n%s\n' "$POINTER_MARKER" "$text" >> "$file"
    return 1
}

# 安装一个目标 agent:参数为 名称、技能目录、指针文件(空=无)
install_target() {
    name="$1"; skills_dir="$2"; pointer_file="$3"
    mkdir -p "$skills_dir"
    for skill in $SKILL_NAMES; do
        src="$SKILLS_SRC/$skill"
        dst="$skills_dir/$skill"
        if [ -d "$dst" ]; then
            if [ "$FORCE" = "1" ]; then
                rm -rf "$dst"
                cp -R "$src" "$dst"
                echo "[覆盖] $name: $skill"
                installed=$((installed + 1))
            else
                echo "[跳过] $name: $skill 已存在(如需覆盖请加 --force)"
                skipped=$((skipped + 1))
            fi
        else
            cp -R "$src" "$dst"
            echo "[安装] $name: $skill"
            installed=$((installed + 1))
        fi
    done
    if [ -n "$pointer_file" ]; then
        append_pointer "$pointer_file" "$POINTER_LINE"
        rc=$?
        case "$rc" in
            0) echo "[指针] $name: $pointer_file 已含 env-know-how 标记,跳过"; pointer_skip=$((pointer_skip + 1)) ;;
            1) echo "[指针] $name: 已追加到 $pointer_file"; pointer_done=$((pointer_done + 1)) ;;
            2) echo "[指针] $name: 未找到 $pointer_file,跳过(不创建新文件)"; pointer_skip=$((pointer_skip + 1)) ;;
        esac
    fi
    create_local_ops "$skills_dir"
}

# ---- 探测已安装的 agent,命中才调用 ----
found=0
if [ -d "$HOME/.codex" ]; then
    install_target "Codex" "$HOME/.agents/skills" "$HOME/.codex/AGENTS.md"
    found=1
fi
if [ -d "$HOME/.claude" ]; then
    install_target "Claude Code" "$HOME/.claude/skills" "$HOME/.claude/CLAUDE.md"
    found=1
fi
if [ -d "$HOME/.dsh" ]; then
    install_target "DeepSeek Harness" "$HOME/.dsh/skills" ""
    found=1
fi
if [ -d "$HOME/.workbuddy" ]; then
    echo "警告:检测到 ~/.workbuddy:WorkBuddy 技能经【技能市场】安装 /【创建技能】生成,无本地技能目录,本安装器不处理。如需上架,见 INSTALL.md「WorkBuddy 专用说明」。" >&2
fi

if [ "$found" = "0" ]; then
    echo "未检测到受支持的 agent 用户目录(Codex / Claude Code / DeepSeek Harness)。"
    echo "已知工具但目录不在这几个:请按 INSTALL.md 的「常见问题」提供信息。"
    exit 0
fi

echo ""
echo "完成:安装/覆盖 $installed 个技能,跳过 $skipped 个,追加指针 $pointer_done 个。"
echo "提示:打开对应 agent 的【新】会话并询问技能列表,确认 common-ops / windows-pwsh-ops / unix-shell-ops 已出现。"
