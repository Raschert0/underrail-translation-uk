"""Зводить усі style.yaml в один оглядовий індекс STYLE-dialogs-uk.md.

347 розкиданих YAML неможливо охопити оком. Індекс — це те, що робить
неузгодженість помітною: два сусіди з однієї локації, до яких звертаються
по-різному без причини, або фракція, чиї члени розійшлися в регістрі.

    python tools/build_style_index.py
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

import yaml

SCOPE = ("dialogs/characters", "dialogs/events")

# Префікси вузлів — локації та фракції. Дають групування, за яким видно розбіжності.
PREFIXES = {
    "cc_": "Центральне Місто", "fo_": "Ливарня", "tch_": "Інститут Тчорта",
    "jy_": "Звалище", "up_": "Верхня Underrail", "ch_": "Табір Хатор",
    "fd_": "Фортеця", "pb_": "Протекторський блокпост", "dun_": "Підземелля",
    "rc_": "Залізничний Переїзд", "lux_": "Люксембург", "le_": "Форт Апогей",
    "sgs_": "Станція Саут-Гейт", "pir_": "Пірати", "lu_": "Лур",
    "rig_": "Платформа", "pr_": "Преторіанці", "dc_": "Глибокі Печери",
}


def group_of(node: str) -> str:
    if node.startswith("dialogs/events"):
        return "Події (events)"
    base = node.split("/")[-1]
    for pref, name in PREFIXES.items():
        if base.startswith(pref):
            return name
    if "/xpbl/" in node:
        return "Expedition (без префікса)"
    return "Основний сюжет (без префікса)"


def main() -> int:
    repo = Path(".").resolve()
    rows: dict[str, list[tuple]] = defaultdict(list)
    cards = missing = 0

    for scope in SCOPE:
        for uk in sorted((repo / scope).rglob("uk.xml")):
            node = uk.parent.relative_to(repo).as_posix()
            card = uk.parent / "style.yaml"
            if not card.exists():
                missing += 1
                continue
            cards += 1
            data = yaml.safe_load(card.read_text(encoding="utf-8")) or {}
            for sp in data.get("speakers") or []:
                addr = sp.get("address") or {}
                voice = sp.get("voice") or {}
                rows[group_of(node)].append((
                    node,
                    sp.get("name", "?"),
                    addr.get("npc_to_player", "—"),
                    addr.get("player_to_npc", "—"),
                    sp.get("confidence", "—"),
                    (voice.get("register") or "").replace("|", "/")[:60],
                ))

    out = [
        "# Індекс стилю діалогів",
        "",
        "Зведення всіх `style.yaml` — один рядок на мовця. Згенеровано",
        "`tools/build_style_index.py`; **не редагувати вручну**, правити треба картки.",
        "",
        f"Карток: {cards} · мовців: {sum(len(v) for v in rows.values())}"
        + (f" · вузлів без картки: {missing}" if missing else ""),
        "",
        "Колонки «до гравця» / «від гравця» — це «ти», «ви» або «змішане». Розбіжність",
        "між сусідами з однієї локації — привід перевірити, а не обов'язково помилка:",
        "STYLE-uk.md §3.2 прямо ставить регістр у залежність від характеру персонажа.",
        "",
    ]
    for group in sorted(rows):
        out += [f"## {group}", "",
                "| Вузол | Мовець | До гравця | Від гравця | Певність | Регістр |",
                "|---|---|---|---|---|---|"]
        for r in sorted(rows[group]):
            out.append("| `{}` | {} | {} | {} | {} | {} |".format(*r))
        out.append("")

    Path("STYLE-dialogs-uk.md").write_text("\n".join(out), encoding="utf-8")
    print(f"Карток: {cards}, мовців: {sum(len(v) for v in rows.values())}, без картки: {missing}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
