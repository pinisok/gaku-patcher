"""
Extract the master localization (key->Japanese) table from a Gakumas Unity APK.

Mirrors the runtime il2cpp hook (GakumasLocalify): the game feeds an
I18nHelper with a 'Localization' TextAsset (CSV: KEY,Japanese). The hook
dumps each key/value pair into local-files/localization.json. This script
reproduces that JSON statically by reading the same TextAsset from the
asset bundle inside the APK.
"""
import csv
import io
import json
import sys
import zipfile
from pathlib import Path

import UnityPy

APK = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("Gaku_3.0.3_embedded.apk")
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("localization.json")
BUNDLE_ENTRY = "assets/bin/Data/datapack.unity3d"
ASSET_NAME = "Localization"


def read_textasset_bytes(data) -> bytes:
    script = getattr(data, "m_Script", None)
    if script is None:
        script = getattr(data, "script", b"")
    if isinstance(script, str):
        return script.encode("utf-8", "surrogateescape")
    return bytes(script)


def find_localization_csv(apk_path: Path) -> str:
    with zipfile.ZipFile(apk_path) as z:
        raw = z.read(BUNDLE_ENTRY)
    env = UnityPy.load(raw)
    for obj in env.objects:
        if obj.type.name != "TextAsset":
            continue
        data = obj.read()
        name = getattr(data, "m_Name", None) or getattr(data, "name", "")
        if name == ASSET_NAME:
            return read_textasset_bytes(data).decode("utf-8")
    raise SystemExit(f"TextAsset {ASSET_NAME!r} not found in {BUNDLE_ENTRY}")


def parse_csv(text: str) -> dict:
    # Header is "KEY,Japanese". Values may contain commas/newlines/quotes,
    # so use a real CSV parser rather than a line split.
    #
    # skipinitialspace=True mirrors the game's I18nHelper parse: unquoted
    # fields have their leading whitespace skipped (e.g.
    #   "achievement.true_end, True Endアチーブメント" -> "True Endアチーブメント",
    # matching the runtime dump), while quoted fields keep every character
    # (e.g. 'common.space," "' -> " "). Trailing whitespace of unquoted
    # fields is preserved.
    reader = csv.reader(io.StringIO(text), skipinitialspace=True)
    rows = [r for r in reader if r and any(c.strip() for c in r)]
    header = rows[0]
    if header[:2] != ["KEY", "Japanese"]:
        raise SystemExit(f"unexpected header: {header!r}")
    result = {}
    dupes = 0
    for row in rows[1:]:
        if len(row) < 2:
            continue
        key, value = row[0], row[1]
        if not key:
            continue
        if key in result:
            dupes += 1
        result[key] = value
    if dupes:
        print(f"  note: {dupes} duplicate keys (last value kept)")
    return result


def main():
    text = find_localization_csv(APK)
    data = parse_csv(text)
    OUT.write_text(
        json.dumps(data, ensure_ascii=False, indent=4) + "\n",
        encoding="utf-8",
    )
    print(f"extracted {len(data)} localization entries -> {OUT}")
    # sanity check against known runtime sample
    for k in ("achievement.true_end", "common.mission_pass_pt"):
        print(f"  {k} = {data.get(k)!r}")


if __name__ == "__main__":
    main()
