# Knowledge Base Template Codex Plugin

This repository is a Codex plugin marketplace for `knowledge-base-template`.

The plugin lives in:

```text
plugins/knowledge-base-template/
```

It provides a lightweight personal knowledge base structure:

- `raw/` keeps original source materials.
- `wiki/` keeps reusable source-linked knowledge pages.
- `context/` keeps long-term background.
- `_system/` keeps prompts, templates, and validation scripts.

## Install

Add this repository as a local Codex plugin marketplace, then install:

```powershell
codex plugin marketplace add D:\project\dgr\KnowledgeBaseTemplate
codex plugin add knowledge-base-template@knowledge-base-template
```

After installing or updating the plugin, start a new Codex thread so the skill is loaded.

## Plugin Name

```text
knowledge-base-template
```

## Use

Ask Codex things like:

```text
把这份资料加入知识库，并更新 wiki。
```

```text
基于这个知识库回答我的问题。
```

```text
检查知识库结构并修复可自动修复的问题。
```
