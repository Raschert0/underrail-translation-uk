# 🇺🇦 Underrail translation project

Ukrainian localization of [Underrail](https://www.underrail.com/), maintained as XLIFF 2.0 files and
translated through Weblate.

## Installation

Download `ukrainian.zip` from the [latest release](../../releases/latest) and extract it into:

```
%path_to_Underrail_installation%\data\localization
```

The archive contains a single `ukrainian` folder, so this leaves you with
`data\localization\ukrainian`. Select the language in the game's options menu.

## Repository layout

```
uk.xml                      # language name shown in-game (translates info.txt)
info.txt                    # shipped verbatim in the release
knowledge/<topic>/uk.xml    # item names, feats, UI strings, tooltips
dialogs/<category>/<node>/  # characters, combatspeak, events, interfacing,
    original.xml            #   randomevents, support
    uk.xml
```

The game ships both a `<key>` and a `<key>_original` entry for every dialog line. `xliff-2-0-agent`
splits that single source file by translatability: `original.xml` holds the `*_original` keys, which
stay in English and are not exposed to Weblate, and `uk.xml` holds the translatable keys.

The `mda:meta` fields are bookkeeping for the tooling — `pos_id` preserves each unit's position in the
original game file, and `version` is the agent's data-schema version, reserved for future migrations.
Both are regenerated on import; only the `<target>` elements in `uk.xml` are hand-owned.

## Для перекладачів

[STYLE-uk.md](STYLE-uk.md) — правила перекладу: звертання, гендерні плейсхолдери, розмітка
рушія, типографіка, великі літери, транслітерація й канонічна термінологія. Канонічні терміни —
у [глосарії проєкту](https://translate.flying-asparagus-factory.cc/projects/underrail/glossary/uk/).

Перед масовими правками запускайте `pwsh tools/check-uk.ps1` — скрипт перевіряє, що розмітка
рушія (`<end>`, `::`, `{N}`, `$(…)`) не постраждала.

## Weblate configuration

Weblate scans the repository for `.xml` translation files and creates one component per leaf
directory, using the **Component discovery** addon:

| Setting | Value |
| --- | --- |
| Regular expression to match translation files against | `(?P<originalHierarchy>.+/)(?P<component>[^/]*)/(?P<language>[^/.]*)(?<!original)\.xml` |
| File format | XLIFF 2.0 translation file |
| Customize the component name | `{{ originalHierarchy }}: {{ component }}` |
| Language filter | `^[^.]+(?<!original)$` |
| Remove components for inexistent files | enabled |

So `dialogs/characters/abram/uk.xml` becomes the component `dialogs/characters/: abram`, with the
language code taken from the filename. Adding a language means adding `<code>.xml` next to each
`uk.xml`.

Two consequences of this pattern are easy to miss:

- The `(?<!original)` lookbehind excludes `original.xml` from discovery entirely. It is not read-only
  in Weblate — it is never imported at all, and exists only to feed the build.
- The pattern requires at least two path segments before the filename, so the top-level `uk.xml` is
  **not** a component. It is the one translation file that has to be edited directly.

Because component removal is enabled, deleting a directory also deletes its component in Weblate,
along with that component's translation history.

## Updating from a new game build

Translation files are regenerated from the game's source strings with
[`xliff-2-0-agent`](https://github.com/Raschert0/xliff-2-0-agent) and merged on top of the existing
XLIFF, so existing translations are preserved.

## Releases

Pushing an `.xml` change to `main` triggers
[the release workflow](.github/workflows/release.yml): it converts the XLIFF tree back into
Underrail's `.loc` format, bundles it with `info.txt` under a `ukrainian/` folder, bumps the patch
version, and publishes `ukrainian.zip` as a pre-release.

The conversion runs on Linux, so the `.loc` writer in `xliff-2-0-agent` has to emit CRLF explicitly —
the game will not parse LF-terminated files and silently falls back to English.
