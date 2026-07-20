"""Перевіряє механічну цілісність карток стилю (style.yaml).

Дзеркалить конвенції tools/check-uk.ps1: параметр шляху, групування проблем за
типом, код виходу 0/1. Написано на Python, а не на PowerShell, бо для PS немає
встановленого YAML-парсера, а картки — YAML.

Перевіряє лише механічно розв'язне. НЕ перевіряє: чи правильно визначено
регістр, чи слушна атрибуція, чи вдалі приклади. Це рішення людини.

    python tools/check_style_cards.py
    python tools/check_style_cards.py --path dialogs/events
"""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path

import yaml

XLIFF_NS = {"x": "urn:oasis:names:tc:xliff:document:2.0"}
SCHEMA_VERSIONS = {1}
SCOPE = ("dialogs/characters", "dialogs/events")
# «н/д» — персонаж не звертається до гравця взагалі (тварина, репліка вбік).
# «невідомо» — мовця або його регістр встановити не вдалося.
# Ці два значення чесніші за вигаданий вибір «ти»/«ви» там, де підстав немає.
ADDRESS_VALUES = {"ти", "ви", "змішане", "н/д", "невідомо"}
REQUIRED_TOP = ("schema_version", "node", "file_id", "units", "speakers")
# Поля-проза мають бути українською — картка існує, щоб полегшити розуміння.
PROSE_FIELDS = ("role", "basis", "register", "reason", "guidance", "note")

problems: list[tuple[str, str, str]] = []


def add(kind: str, where: str, detail: str) -> None:
    problems.append((kind, where, detail))


def unit_ids(uk_xml: Path) -> tuple[set[str], set[str], set[str], int]:
    """Повертає (q-юніти, a-юніти, порожні, усього) з uk.xml, без префікса '=>'.

    Порожні юніти (джерело — самий <end>) — вузли розгалуження діалогу. Вони
    не несуть сигналу про мовця, тож не вимагають атрибуції.
    """
    root = ET.parse(uk_xml).getroot()
    q, a, empty = set(), set(), set()
    for unit in root.iterfind(".//x:unit", XLIFF_NS):
        uid = (unit.get("id") or "").removeprefix("=>")
        (a if uid.startswith("a") else q).add(uid)
        src = unit.find("./x:segment/x:source", XLIFF_NS)
        text = "".join(src.itertext()) if src is not None else ""
        if not text.replace("<end>", "").strip():
            empty.add(uid)
    return q, a, empty, len(q) + len(a)


def load_registry(repo: Path) -> dict[str, str]:
    path = repo / "style" / "registry.yaml"
    if not path.exists():
        add("registry-missing", str(path), "немає style/registry.yaml")
        return {}
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    reg: dict[str, str] = {}
    for c in data.get("characters", []):
        # Складені імена несуть явний slug; для однослівних slug — саме ім'я.
        reg[c.get("slug", c["en"]).lower()] = c["uk"]
    return reg


def check_prose(card_path: str, obj, trail: str = "") -> None:
    """Рекурсивно шукає поля-прозу, що лишилися англійськими або мають хибний апостроф."""
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key in PROSE_FIELDS and isinstance(value, str) and value.strip():
                if not re.search(r"[а-щьюяїієґА-ЩЬЮЯЇІЄҐ]", value):
                    add("prose-not-ukrainian", card_path, f"{trail}{key}: {value[:60]}")
                # Лише апостроф усередині українського слова. Латинські фрагменти
                # зберігають свою типографіку (STYLE §4), тож ain't і ma'am — норма.
                if re.search(r"[а-щьюяїієґА-ЩЬЮЯЇІЄҐ]'[а-щьюяїієґА-ЩЬЮЯЇІЄҐ]", value):
                    add("apostrophe", card_path, f"{trail}{key}: треба ’ (U+2019), не '")
            check_prose(card_path, value, f"{trail}{key}.")
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            check_prose(card_path, item, f"{trail}[{i}].")


def check_card(card: Path, repo: Path, registry: dict[str, str],
               slug_names: dict[str, tuple[str, str]]) -> None:
    rel = card.relative_to(repo).as_posix()
    try:
        data = yaml.safe_load(card.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:
        add("yaml-parse", rel, str(exc).split("\n")[0])
        return
    if not isinstance(data, dict):
        add("yaml-parse", rel, "корінь картки — не словник")
        return

    for key in REQUIRED_TOP:
        if key not in data:
            add("missing-key", rel, f"немає обов'язкового поля «{key}»")
    if data.get("schema_version") not in SCHEMA_VERSIONS:
        add("schema-version", rel, f"невідома версія схеми: {data.get('schema_version')}")

    node_dir = card.parent
    expected_node = node_dir.relative_to(repo).as_posix()
    if data.get("node") != expected_node:
        add("node-mismatch", rel, f"node={data.get('node')}, а тека {expected_node}")

    uk_xml = node_dir / "uk.xml"
    if not uk_xml.exists():
        add("no-uk-xml", rel, "поруч немає uk.xml")
        return

    q_ids, a_ids, empty_ids, total = unit_ids(uk_xml)
    file_id = ET.parse(uk_xml).getroot().find(".//x:file", XLIFF_NS).get("id")
    if data.get("file_id") != file_id:
        add("file-id", rel, f"картка={data.get('file_id')} джерело={file_id}")

    units = data.get("units") or {}
    if units.get("total") != total:
        add("unit-count", rel, f"units.total={units.get('total')}, у uk.xml {total}")

    speakers = data.get("speakers") or []
    if not isinstance(speakers, list) or not speakers:
        add("speakers", rel, "speakers має бути непорожнім списком")
        return

    claimed: dict[str, str] = {}
    default_slugs, unknown_units = [], set()

    for sp in speakers:
        slug = sp.get("slug", "?")
        where = f"{rel} :: {slug}"
        conf = sp.get("confidence")
        if conf not in {"certain", "probable", "unknown"}:
            add("confidence", where, f"невідоме значення: {conf}")

        if slug == "narrator":
            # Службовий мовець: нарація не персонаж і в реєстрі не значиться.
            pass
        elif slug.startswith("unknown"):
            for field in ("reason", "guidance"):
                if not sp.get(field):
                    add("unknown-speaker", where, f"невстановлений мовець без «{field}»")
        else:
            name = sp.get("name")
            if slug.lower() not in registry:
                add("slug-unregistered", where, "slug не знайдено в style/registry.yaml")
            elif name and registry[slug.lower()] != name:
                add("name-mismatch", where,
                    f"картка={name}, реєстр={registry[slug.lower()]}")
            if slug in slug_names and slug_names[slug][0] != name:
                add("slug-conflict", where,
                    f"той самий slug має інше ім'я в {slug_names[slug][1]}: {slug_names[slug][0]}")
            elif name:
                slug_names[slug] = (name, rel)

        addr = sp.get("address") or {}
        for key in ("npc_to_player", "player_to_npc"):
            val = addr.get(key)
            if val is not None and val not in ADDRESS_VALUES:
                add("address-value", where, f"{key}={val!r}, очікується ти/ви/змішане")

        units_field = sp.get("units")
        if units_field == "default":
            default_slugs.append(slug)
            continue
        if not isinstance(units_field, list):
            add("units-field", where, "units має бути списком або «default»")
            continue
        for uid in units_field:
            if uid in a_ids:
                add("player-unit-to-npc", where, f"{uid} — репліка гравця, не NPC")
            elif uid not in q_ids:
                add("unknown-unit", where, f"{uid} немає в uk.xml")
            elif uid in claimed:
                add("unit-double-claim", where, f"{uid} вже заявлено мовцем {claimed[uid]}")
            else:
                claimed[uid] = slug
        if conf == "unknown":
            unknown_units.update(units_field)

        for uid in sp.get("evidence") or []:
            if uid not in q_ids and uid not in a_ids:
                add("unknown-unit", where, f"evidence {uid} немає в uk.xml")

    if len(default_slugs) > 1:
        add("multiple-defaults", rel, f"units: default у кількох мовців: {default_slugs}")
    if not default_slugs:
        uncovered = q_ids - claimed.keys() - empty_ids
        if uncovered:
            add("units-uncovered", rel,
                f"{len(uncovered)} q-юнітів не належать жодному мовцю")

    declared = set(data.get("unattributed_units") or [])
    if declared != unknown_units:
        add("unattributed-mismatch", rel,
            f"unattributed_units={sorted(declared)}, а confidence:unknown покриває {sorted(unknown_units)}")

    for item in data.get("examples") or []:
        if item.get("status") != "proposed":
            add("example-status", rel, f"приклад {item.get('unit')} без status: proposed")
        frag = item.get("uk_fragment") or ""
        for m in re.finditer(r"\$\(#([^)]*)\)", frag):
            if m.group(1) and re.fullmatch(r"[\x00-\x7F]+", m.group(1)):
                add("gender-latin", rel, f"неперекладений плейсхолдер: {m.group(0)}")

    check_prose(rel, data)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", default=".")
    args = parser.parse_args()
    repo = Path(args.path).resolve()

    registry = load_registry(repo)
    slug_names: dict[str, tuple[str, str]] = {}

    node_dirs = sorted({p.parent for scope in SCOPE
                        for p in (repo / scope).rglob("uk.xml")})
    cards = 0
    for node_dir in node_dirs:
        card = node_dir / "style.yaml"
        if not card.exists():
            add("card-missing", node_dir.relative_to(repo).as_posix(), "немає style.yaml")
            continue
        cards += 1
        check_card(card, repo, registry, slug_names)

    print(f"Вузлів у межах перевірки: {len(node_dirs)}")
    print(f"Карток знайдено:          {cards}")

    if not problems:
        print("OK — порушень не знайдено.")
        return 0

    print(f"Знайдено порушень: {len(problems)}")
    grouped = defaultdict(list)
    for kind, where, detail in problems:
        grouped[kind].append((where, detail))
    for kind, items in sorted(grouped.items(), key=lambda kv: -len(kv[1])):
        print(f"\n=== {kind}: {len(items)} ===")
        for where, detail in items[:20]:
            print(f"  {where} — {detail}")
        if len(items) > 20:
            print(f"  … ще {len(items) - 20}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
