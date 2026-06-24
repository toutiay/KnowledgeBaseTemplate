# Knowledge Base Template Codex 插件

这是一个 Codex 插件市场仓库，里面提供 `knowledge-base-template` 插件。

插件目录是：

```text
plugins/knowledge-base-template/
```

这个插件用于维护一个轻量个人知识库：

- `raw/` 保存原始资料和证据。
- `wiki/` 保存整理后的、可复用的知识页。
- `context/` 保存长期背景和项目上下文。
- `_system/` 保存提示词、模板和校验脚本。

## 安装

本仓库已经包含默认的 personal marketplace 配置：

```text
.agents/plugins/marketplace.json
```

在本仓库目录下安装插件：

```powershell
codex plugin add knowledge-base-template@personal
```

如果你的环境没有自动发现本仓库的 marketplace，或者你想把这个仓库作为一个非默认本地市场显式注册，再运行：

```powershell
codex plugin marketplace add D:\project\dgr\KnowledgeBaseTemplate
codex plugin add knowledge-base-template@personal
```

Windows 上如果 `codex.exe` 命令被 WindowsApps 别名拦截并返回 `Access is denied`，可以改用用户级插件运行时：

```powershell
& "$env:USERPROFILE\.codex\plugins\.plugin-appserver\codex.exe" plugin add knowledge-base-template@personal
```

安装或更新插件后，请新开一个 Codex 线程，这样 Codex 才会加载新的 skill。

## 插件名

```text
knowledge-base-template
```

## 使用示例

你可以这样对 Codex 说：

```text
把这份资料加入知识库，并更新 wiki。
```

```text
基于这个知识库回答我的问题。
```

```text
检查知识库结构并修复可自动修复的问题。
```
