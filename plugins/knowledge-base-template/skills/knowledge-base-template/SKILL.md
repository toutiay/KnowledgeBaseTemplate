---
name: knowledge-base-template
description: 当用户想维护轻量个人知识库时使用：把文章、笔记、PDF、转写稿、会议纪要、想法或链接入库到 raw/ 和 wiki/；更新或合并 wiki 页面；基于知识库问答；校验知识库结构。
---

# Knowledge Base Template

这个 skill 用于让 Codex 按固定结构维护一个轻量个人知识库。

## 目录约定

插件安装目录只保存规则、提示词、模板和脚本；真实知识库内容必须写入固定的数据目录，不能写入插件缓存目录。

固定知识库根目录按下面顺序确定：

1. 如果用户在当前请求里明确指定知识库目录，使用用户指定目录。
2. 如果用户级配置文件 `%USERPROFILE%\.codex\knowledge-base-template\config.json` 存在，读取其中的 `knowledgeBaseRoot`。
3. 如果系统环境变量 `CODEX_KB_HOME` 存在，使用它指向的目录。
4. 否则使用默认目录：`%USERPROFILE%\Documents\Codex\KnowledgeBase`。

在默认 Windows 用户 `admin` 下，默认知识库根目录是：

```text
C:\Users\admin\Documents\Codex\KnowledgeBase
```

知识库根目录里面包含：

- `raw/`：原始资料层，用来保存来源材料和证据。
- `wiki/`：知识页层，用来保存整理后的、可复用的知识。
- `context/`：长期背景、项目约束和补充上下文。
- `_system/` 不属于知识库数据目录，它在插件安装目录中，给 Codex 使用提示词、模板和校验脚本。

无论在哪个项目、哪个聊天线程中触发此 skill，只要没有显式指定其他知识库目录，都必须读写同一个固定知识库根目录。不要把 `raw/`、`wiki/` 或 `context/` 写入 `.codex/plugins/cache/...` 下的插件安装缓存，也不要写入当前项目目录。

## 触发场景

当用户提出以下需求时，使用这个 skill：

- 把资料加入知识库
- 入库、归档、保存或整理原始内容
- 新建、更新、合并或去重 wiki 页面
- 基于这个知识库回答问题
- 生成索引页、来源页、主题页、概念页、流程页或对比页
- 校验或修复知识库结构

## 入库规则

处理入库或更新请求时：

1. 先阅读 `_system/prompts/ingest-and-update-wiki.md`。
2. 先解析固定知识库根目录；如果配置文件不存在，可以运行 `_system/scripts/initialize-kb.ps1` 询问用户知识库存储地址。用户直接回车时使用默认目录。
3. 如果目录不存在，创建 `raw/`、`wiki/`、`context/` 以及标准 wiki 子目录。
4. 新建页面前，先检查固定知识库根目录下已有 `wiki/` 页面，避免重复建页。
5. 将原始资料保存或引用到固定知识库根目录下的 `raw/`。
6. 根据内容类型，在固定知识库根目录下对应的 `wiki/` 子目录中新建或更新页面：
   - `00 索引/`：索引和导航。
   - `10 来源/`：来源页。
   - `20 主题/`：主题综合整理。
   - `30 概念/`：概念、术语和定义。
   - `40 流程/`：步骤、流程和操作手册。
   - `50 对比/`：方案、观点或工具对比。
7. 优先更新、合并已有页面，不要轻易制造重复页面。
8. 重要结论尽量追溯到 `raw/` 来源。
9. 不确定的内容要明确标记，不要编造。

## 基于知识库问答

回答知识库相关问题时：

1. 先阅读 `_system/prompts/ask-my-kb.md`。
2. 先解析固定知识库根目录。
3. 优先读取固定知识库根目录下的 `wiki/`，因为它是整理后的知识层。
4. 当来源证据重要，或 `wiki/` 信息不足时，回查固定知识库根目录下的 `raw/`。
5. 如果 `wiki/` 和 `raw/` 冲突，以 `raw/` 为准，并指出冲突。
6. 如需补充外部知识，必须明确标注“外部补充”。

## 校验

当用户要求校验或修复知识库时，在插件根目录运行。默认会校验固定知识库根目录：

```powershell
powershell -ExecutionPolicy Bypass -File _system/scripts/validate-kb.ps1
```

如果用户指定了其他知识库目录，显式传入：

```powershell
powershell -ExecutionPolicy Bypass -File _system/scripts/validate-kb.ps1 -Root "D:\path\to\KnowledgeBase"
```

当用户要求严格 schema 检查时运行：

```powershell
powershell -ExecutionPolicy Bypass -File _system/scripts/validate-kb.ps1 -StrictSchema
```

如果校验报告缺少目录、断链或其他可自动修复的问题，优先在知识库根目录内修复，然后重新运行校验。

## 输出要求

每次修改知识库后，向用户说明：

- 新增或更新了哪些 raw 文件
- 新增、更新或合并了哪些 wiki 页面
- 提炼出的关键结论
- 仍需用户确认的冲突或问题
