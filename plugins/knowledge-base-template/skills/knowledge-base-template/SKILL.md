---
name: knowledge-base-template
description: Use when the user wants to maintain a lightweight personal knowledge base: ingest raw articles, notes, PDFs, transcripts, meeting notes, ideas, or links into raw/ and wiki/; update or merge wiki pages; answer from this knowledge base; or validate the knowledge base structure.
---

# Knowledge Base Template

This skill turns a plugin directory into a lightweight personal knowledge base for Codex.

## Directory Contract

The knowledge base root is the plugin root that contains:

- `raw/`: original source materials and evidence.
- `wiki/`: organized, reusable knowledge pages.
- `context/`: long-term background and project context.
- `_system/`: prompts, templates, and validation scripts for Codex.

When this plugin is installed, resolve the knowledge base root as two directories above this file:

```text
skills/knowledge-base-template/SKILL.md -> ../.. -> plugin root
```

## Triggered Workflows

Use this skill when the user asks to:

- add material to the knowledge base
- ingest, archive, preserve, or organize raw content
- create, update, merge, or deduplicate wiki pages
- answer questions based on the knowledge base
- generate an index, topic page, source page, concept page, process page, or comparison page
- validate or repair the knowledge base structure

## Ingest Rules

For ingest/update requests:

1. Read `_system/prompts/ingest-and-update-wiki.md`.
2. Inspect existing `wiki/` pages before creating new pages.
3. Save or reference the original material under `raw/`.
4. Create or update pages under the matching `wiki/` section:
   - `00 索引/` for indexes and navigation.
   - `10 来源/` for source pages.
   - `20 主题/` for topic synthesis.
   - `30 概念/` for concepts and terms.
   - `40 流程/` for procedures and workflows.
   - `50 对比/` for comparisons.
5. Prefer updating and merging existing pages over duplicating pages.
6. Keep claims traceable to raw sources whenever possible.
7. Mark uncertainty explicitly instead of inventing missing facts.

## Question Answering

For questions about the knowledge base:

1. Read `_system/prompts/ask-my-kb.md`.
2. Prefer `wiki/` for synthesized knowledge.
3. Check `raw/` when the source evidence matters or when `wiki/` is incomplete.
4. If `wiki/` and `raw/` conflict, treat `raw/` as authoritative and mention the conflict.
5. Clearly label any external knowledge as external.

## Validation

For validation or repair requests, run from the plugin root:

```powershell
powershell -ExecutionPolicy Bypass -File _system/scripts/validate-kb.ps1
```

Use strict validation when the user asks for schema checks:

```powershell
powershell -ExecutionPolicy Bypass -File _system/scripts/validate-kb.ps1 -StrictSchema
```

If validation reports missing directories or fixable structure problems, repair them within the knowledge base root and rerun validation.

## Output Expectations

After changing the knowledge base, report:

- raw files added or updated
- wiki files added, updated, or merged
- key conclusions extracted
- unresolved conflicts or questions needing user confirmation
