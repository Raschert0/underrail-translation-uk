# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A Ukrainian localization of the game **Underrail**, stored as XLIFF 2.0 translation memory. There is **no application code here** — the repo is pure translation data (2146 `.xml` files) plus one CI workflow. Translations are edited through **Weblate** (nearly every commit is `Translated using Weblate (Ukrainian)`), so hand-editing files is the exception, not the norm.

## Build / release

There is nothing to build locally. Everything happens in [.github/workflows/release.yml](.github/workflows/release.yml), triggered on pushes to `main` that touch `**/*.xml`:

1. Checks out the private converter repo `Raschert0/xliff-2-0-agent` (needs `XLIFF_2_0_DEPLOY_KEY`).
2. Writes a `config.yaml` pointing `xliff_dir` at this repo and `output_dir` at `output/`.
3. Runs `python main.py --mode read-xliff-and-create-loc` — converts the XLIFF tree into Underrail's `.loc` localization files.
4. Copies `info.txt`, zips to `ukrainian.zip`, auto-bumps the patch version from the latest tag, and publishes a **pre-release**.

The XLIFF→LOC conversion logic lives in the separate `xliff-2-0-agent` repo, not here. To reproduce a build locally you must clone that repo and supply the same `config.yaml` shape.

## Layout and the `original.xml` / `uk.xml` pairing

```
uk.xml                      # top-level: translates info.txt (the language name shown in-game)
info.txt                    # "Українська" — copied verbatim into the release
knowledge/<topic>/uk.xml    # 59 topics: item names, feats, UI strings, tooltips — uk.xml only
dialogs/<category>/<node>/  # 1042 dialog nodes across characters, combatspeak, events,
    original.xml            #   interfacing, randomevents, support
    uk.xml
```

Each XLIFF `<file id>` mirrors the game's own path (`dialogs\characters\abram.txt`, `knowledge\abilitynames.txt`) using **backslashes** — preserve them.

The two files are not source-and-target. The game ships both a `<key>` and a `<key>_original` entry for every dialog line, and the pair here is that single source file **split by translatability**:

- `original.xml` — the game's `*_original` keys, English kept verbatim (`source` == `target`), states `reviewed`/`final`. These ship untranslated; do not touch the targets.
- `uk.xml` — the plain keys, carrying the Ukrainian, state `translated`.

Verified across all 1042 dialog nodes with no exceptions: 1:1 unit counts, and every `uk.xml` id is its `original.xml` id minus the `_original` suffix. `knowledge/` has no `original.xml` — those strings have no `_original` counterpart in the game files.

`mda:meta` fields are bookkeeping for `xliff-2-0-agent`, not game data:

- `pos_id` records each unit's position in the original game file. The two key families are interleaved there, which is why `original.xml` ends up all-odd and `uk.xml` all-even — an artifact of the split, not a rule to maintain. Ordering likely doesn't matter to the game; it's kept for consistency. Never hand-renumber.
- `version` is the agent's own data-schema version (`1` everywhere), reserved for future migrations. Not a game or content version.

## Updating from a new game build

Files are regenerated from the game's source strings with `xliff-2-0-agent` and merged on top of the existing XLIFF, so existing translations survive. The practical consequence: **`original.xml` and all `mda:meta` values are machine-generated and will be overwritten on the next import.** Editing them isn't just discouraged — the work gets clobbered. Only `<target>` elements in `uk.xml` are hand-owned.

## Weblate

Translations are edited in Weblate, which discovers components automatically (Component discovery addon) — one component per leaf directory:

```
Match:           (?P<originalHierarchy>.+/)(?P<component>[^/]*)/(?P<language>[^/.]*)(?<!original)\.xml
Format:          XLIFF 2.0 translation file
Component name:  {{ originalHierarchy }}: {{ component }}   →  "dialogs/characters/: abram"
Language filter: ^[^.]+(?<!original)$
Remove components for inexistent files: enabled
```

Two consequences worth knowing before editing anything by hand:

- **`original.xml` is invisible to Weblate**, excluded by the `(?<!original)` lookbehind — not read-only, simply never imported. It exists only for the build.
- **The top-level [uk.xml](uk.xml) is *not* a Weblate component.** The pattern needs at least two path segments before the filename, so a root-level file can't match. It translates `info.txt` (the language name shown in-game) and is the one translation file that must be edited directly.

The language code comes from the filename, so a second language would be `<code>.xml` alongside each `uk.xml`. Since component removal is enabled, deleting a directory deletes its component and its translation history.

## Game markup that must survive translation

Targets contain engine syntax that is **not** prose:

- `<end>` (XML-escaped as `&lt;end&gt;`) terminates a dialog line — always keep it, at the end.
- `$(#masc/fem)` — player-gender conditional. Translate *both* branches into Ukrainian gendered forms: `you helped` → `ти $(#допоміг/допомогла)`, `sir/ma'am` → `$(#пане/пані)`. Capitalization of the branch matters (`$(#Пане/Пані)`). Ukrainian needs **more** of these than English has, because its past tense and adjectives are gendered — adding a placeholder where the source had none is correct, not a liberty.
- `::text::` — stage directions/narration, translated as prose but the `::` delimiters stay.
- Unit `id` and `name` attributes are the game's lookup keys (`=&gt;q1`, `::Telekinetic Punch`) — never edit them.

Files are UTF-8; `uk.xml` files written by the pipeline use `<?xml version="1.0" encoding="UTF-8"?>` while agent-generated ones use single quotes — don't churn that line.

## Translation conventions

[STYLE-uk.md](STYLE-uk.md) is the authoritative style guide — forms of address, gender
placeholders, typography, capitalization, transliteration, UI voice, and canonical terminology.
It was derived from the human-edited segments, so it reflects actual practice, not aspiration.
Read it before touching any `<target>`. Canonical terms live in the
[project glossary](https://translate.flying-asparagus-factory.cc/projects/underrail/glossary/uk/),
a Weblate component — not a file in this repo.

`tools/check-uk.ps1` verifies the mechanical invariants (`<end>` preserved, `::` counts match,
`{N}` and `$(context.…)` sets match, no untranslated Latin inside `$(#…)`) across every
human-edited segment. Run it after any bulk edit; it must report zero.

Note the state distinction: `<target state="needs-translation">` is raw machine translation
(94.7% of the corpus), `<target state="translated">` is human-reviewed (5.3%). Style rules and
audits apply to the latter — the former will be retranslated wholesale.

## Working here

- Prefer targeted edits to individual `<target>` elements; a bulk reformat of 2146 files would produce an unreviewable Weblate diff.
- Editing `uk.xml` files directly competes with Weblate, which owns them — expect conflicts on its next push. The root `uk.xml` is the exception; nothing else edits it.
- Any `.xml` change pushed to `main` cuts a release, so batch edits into one push.
- `.idea/` is gitignored; `README.md` is currently untracked and near-empty.
