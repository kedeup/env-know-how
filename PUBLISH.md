# PUBLISH.md — 发布到 GitHub 指南

> 目标:把 `env-know-how` 发布为**公开仓库**,让任何用户「一句话」装上(Codex / Claude / DSH 走安装器,WorkBuddy 走技能市场)。
> 前置:本机需已安装 git,并按 GitHub 官方指引完成身份与凭据配置(本仓库不记录任何本机账号/路径信息)。

## 第 0 步:创建仓库(已完成)

仓库已创建:**https://github.com/kedeup/env-know-how** (Public)。若你在其他机器上再建,参照:https://github.com/new → 名称 `env-know-how`、Public、不勾选 README/.gitignore/license。

## 第 1 步:进入本包目录

```powershell
cd <本仓库目录>
```

## 第 2 步:初始化并推送

```powershell
git init
git add .
git commit -m "v0.1: env-know-how 环境知识包骨架(Codex/DSH 安装器 + WorkBuddy 适配包)"
git branch -M main
git remote add origin https://github.com/kedeup/env-know-how.git
git push -u origin main
```

## 第 3 步:验证

浏览器打开仓库地址,确认 README.md / INSTALL.md / install.ps1 / install.sh / skills/ / workbuddy-pack/ 都在。

## 后续更新

```powershell
git add -A
git commit -m "更新说明"
git push
```

## 注意事项

- 仓库里**不包含**任何密钥/凭据;`workbuddy-pack` 里的 `author: kedeup` 可按需替换成你的署名;
- 若 `git push` 报 `Failed sending data to the peer` 且本机配置了全局 `http.proxy`,但**直连 github.com:443 通畅**时,可用一次性参数绕过代理重试(不改任何配置):
  ```powershell
  git -c http.proxy= push -u origin main
  ```
- 若身在受限网络,`git push` 失败多为网络问题,可重试或配置代理。
