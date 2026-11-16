#!/usr/bin/env python3
"""Génère la narration de Lumière avec Piper (synthèse vocale libre, hors ligne).

Lit les textes des histoires (app/assets/stories/*/story.json) et les phrases
communes (app/assets/lines/common.json), puis crée un fichier MP3 par phrase et
par variante d'âge. Seules les phrases nouvelles ou modifiées sont régénérées
(empreintes dans tools/narration/manifest.json).

Prérequis (une seule fois) :
    pip install piper-tts
    + une voix française, ex. fr_FR-siwis-medium (.onnx et .onnx.json) depuis
      https://huggingface.co/rhasspy/piper-voices (dossier fr/fr_FR/siwis/medium)
    + ffmpeg dans le PATH

Utilisation, depuis la racine du dépôt :
    python tools/narration/generate.py --voice chemin/vers/fr_FR-siwis-medium.onnx
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "app" / "assets"
MANIFEST = Path(__file__).with_name("manifest.json")

# Réglages de la voix : un peu plus lente que la normale, pour les enfants.
LENGTH_SCALE = "1.12"
SENTENCE_SILENCE = "0.35"
SETTINGS = f"{LENGTH_SCALE}|{SENTENCE_SILENCE}|v1"


def variants(value) -> dict[str, str]:
    """Une phrase narrée : chaîne (pour tous) ou objet par âge (voir NarratedText)."""
    if isinstance(value, str):
        return {"all": value}
    return dict(value)


def story_lines(story: dict) -> dict[str, dict[str, str]]:
    """Mêmes clés que Story.fromJson (lib/story/story.dart)."""
    lines: dict[str, dict[str, str]] = {"intro": variants(story["intro"])}
    for scene in story["scenes"]:
        sid = scene["id"]
        lines[f"scene.{sid}"] = variants(scene["text"])
        lines[f"scene.{sid}.action"] = variants(scene["action"])
        if scene.get("after") is not None:
            lines[f"scene.{sid}.after"] = variants(scene["after"])
    games = story["games"]
    for name in ("chronology", "seek", "memory"):
        lines[f"game.{name}"] = variants(games[name]["instructions"])
    lines["verse.reading"] = variants(story["verse"]["spoken"])
    lines["game.verse"] = variants(story["verse"]["instructions"])
    lines["reward"] = variants(story["reward"])
    return lines


def speakable(text: str) -> str:
    """Prépare le texte pour la voix (guillemets, abréviations…)."""
    text = text.replace("«", "").replace("»", "").replace("…", "...")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def jobs() -> list[tuple[Path, str]]:
    result: list[tuple[Path, str]] = []
    for story_file in sorted((ASSETS / "stories").glob("*/story.json")):
        story = json.loads(story_file.read_text(encoding="utf-8"))
        for key, texts in story_lines(story).items():
            for variant, text in texts.items():
                result.append((ASSETS / "stories" / story["id"] / "audio" / f"{key}.{variant}.mp3", text))
    common = json.loads((ASSETS / "lines" / "common.json").read_text(encoding="utf-8"))
    for key, value in common.items():
        for variant, text in variants(value).items():
            result.append((ASSETS / "audio" / "lines" / f"{key}.{variant}.mp3", text))
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--voice", required=True, help="fichier .onnx de la voix Piper")
    parser.add_argument("--piper", default="piper", help="commande piper (défaut : piper)")
    parser.add_argument("--force", action="store_true", help="tout régénérer")
    args = parser.parse_args()

    if shutil.which("ffmpeg") is None:
        print("ffmpeg est introuvable : installez-le et ajoutez-le au PATH.", file=sys.stderr)
        return 1

    manifest: dict[str, str] = {}
    if MANIFEST.exists() and not args.force:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

    voice = Path(args.voice).name
    wanted = jobs()
    keep = set()
    done = 0
    for target, text in wanted:
        rel = target.relative_to(ASSETS).as_posix()
        keep.add(rel)
        digest = hashlib.sha256(f"{voice}|{SETTINGS}|{text}".encode()).hexdigest()[:16]
        if manifest.get(rel) == digest and target.exists():
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory() as tmp:
            wav = Path(tmp) / "line.wav"
            subprocess.run(
                [args.piper, "-m", args.voice, "-f", str(wav), "--length-scale", LENGTH_SCALE,
                 "--sentence-silence", SENTENCE_SILENCE],
                input=speakable(text).encode("utf-8"), check=True, capture_output=True,
            )
            subprocess.run(
                ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-af", "apad=pad_dur=0.25",
                 "-ac", "1", "-ar", "22050", "-codec:a", "libmp3lame", "-b:a", "40k", str(target)],
                check=True,
            )
        manifest[rel] = digest
        done += 1
        print(f"  {rel}")

    # Retire les fichiers dont la phrase n'existe plus.
    for rel in sorted(set(manifest) - keep):
        (ASSETS / rel).unlink(missing_ok=True)
        del manifest[rel]
        print(f"  supprimé : {rel}")

    MANIFEST.write_text(json.dumps(dict(sorted(manifest.items())), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"{done} phrase(s) générée(s), {len(wanted)} au total.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
