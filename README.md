# Knowledge Base Template Codex 插件

这是一个 Codex 插件市场仓库，里面提供 `knowledge-base-template` 插件。

插件目录是：

```text
plugins/knowledge-base-template/
```

这个插件用于维护一个轻量个人知识库。插件本身和知识库数据是分开的：

- 插件安装到 Codex 用户级插件缓存，例如 `C:\Users\admin\.codex\plugins\cache\personal\knowledge-base-template\0.1.0`。
- 安装或初始化时会询问知识库存储地址；用户输入地址就使用该地址，直接回车就使用默认地址。
- 用户选择会保存到 `%USERPROFILE%\.codex\knowledge-base-template\config.json`。
- 如果没有配置文件，知识库内容默认写入 `%USERPROFILE%\Documents\Codex\KnowledgeBase`。

默认知识库目录结构：

- `raw/` 保存原始资料和证据。
- `wiki/` 保存整理后的、可复用的知识页。
- `context/` 保存长期背景和项目上下文。
- `_system/` 保存提示词、模板和校验脚本，位于插件目录内，不是知识库数据目录。

在 Windows 用户 `admin` 下，默认数据目录是：

```text
C:\Users\admin\Documents\Codex\KnowledgeBase
```

无论你在哪个项目、哪个聊天线程里说“加入知识库”，只要没有显式指定其他目录，都会写入这一个固定目录下的 `raw/` 和 `wiki/`，不会写入带版本号的插件安装缓存。

## 安装

本仓库已经包含默认的 personal marketplace 配置：

```text
.agents/plugins/marketplace.json
```

推荐安装策略：

1. 优先使用 GitHub zip 下载整个仓库。
2. 解压到本地固定插件目录，例如 `D:\CodexPlugins\KnowledgeBaseTemplate-master`。
3. 从这个本地固定目录注册 marketplace 并安装插件。
4. 如果 GitHub zip 下载失败，再退回 GitHub API 或 GitHub 连接器逐文件读取。

公开仓库可直接用 GitHub zip 安装：

```powershell
$zip = "$env:TEMP\KnowledgeBaseTemplate.zip"
$dest = "D:\CodexPlugins"
$repo = Join-Path $dest "KnowledgeBaseTemplate-master"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Invoke-WebRequest `
  -Uri "https://github.com/toutiay/KnowledgeBaseTemplate/archive/refs/heads/master.zip" `
  -OutFile $zip
Expand-Archive -Path $zip -DestinationPath $dest -Force

codex plugin marketplace add $repo
codex plugin add knowledge-base-template@personal
powershell -ExecutionPolicy Bypass -File "$repo\plugins\knowledge-base-template\_system\scripts\initialize-kb.ps1"
```

安装插件：

```powershell
codex plugin add knowledge-base-template@personal
```

然后初始化知识库目录。初始化脚本会询问知识库存储地址：

```powershell
powershell -ExecutionPolicy Bypass -File plugins\knowledge-base-template\_system\scripts\initialize-kb.ps1
```

提示输入目录时：

- 输入一个目录：使用你输入的目录。
- 直接回车：使用默认目录 `%USERPROFILE%\Documents\Codex\KnowledgeBase`。

如果你的环境没有自动发现本仓库的 marketplace，或者你想把这个仓库作为一个非默认本地市场显式注册，再运行：

```powershell
codex plugin marketplace add D:\project\dgr\KnowledgeBaseTemplate
codex plugin add knowledge-base-template@personal
powershell -ExecutionPolicy Bypass -File plugins\knowledge-base-template\_system\scripts\initialize-kb.ps1
```

Windows 上如果 `codex.exe` 命令被 WindowsApps 别名拦截并返回 `Access is denied`，可以改用用户级插件运行时：

```powershell
& "$env:USERPROFILE\.codex\plugins\.plugin-appserver\codex.exe" plugin add knowledge-base-template@personal
powershell -ExecutionPolicy Bypass -File plugins\knowledge-base-template\_system\scripts\initialize-kb.ps1
```

安装或更新插件后，请新开一个 Codex 线程，这样 Codex 才会加载新的 skill。

## 固定知识库目录

默认固定目录：

```powershell
$env:USERPROFILE\Documents\Codex\KnowledgeBase
```

初始化脚本会询问知识库存储地址，并写入用户级配置：

```powershell
powershell -ExecutionPolicy Bypass -File plugins\knowledge-base-template\_system\scripts\initialize-kb.ps1
```

也可以用参数直接指定，不进入交互：

```powershell
powershell -ExecutionPolicy Bypass -File plugins\knowledge-base-template\_system\scripts\initialize-kb.ps1 -Root "D:\KnowledgeBase"
```

校验默认知识库目录：

```powershell
powershell -ExecutionPolicy Bypass -File plugins\knowledge-base-template\_system\scripts\validate-kb.ps1
```

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
