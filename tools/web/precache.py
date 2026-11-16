#!/usr/bin/env python3
"""Prépare la version web de Lumière pour le hors ligne.

À lancer après `flutter build web` :
    python tools/web/precache.py app/build/web

- écrit precache.json : les fichiers à garder dès l'installation (tout sauf
  la narration et les bruitages, gardés quand on les écoute) ;
- inscrit dans sw.js une version propre à cette construction.
"""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

SKIP_SUFFIXES = {".mp3", ".map", ".symbols"}
SKIP_NAMES = {"sw.js", "precache.json", "flutter_service_worker.js", "NOTICES", ".last_build_id"}
# Les moteurs d'affichage : un seul sert, selon le navigateur. La page signale
# au service worker celui qu'elle a chargé (voir index.html), on ne précharge
# donc aucun d'eux.
SKIP_DIRS = ("canvaskit/",)


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "app/build/web").resolve()
    sw = root / "sw.js"
    if not sw.exists():
        print(f"sw.js introuvable dans {root}", file=sys.stderr)
        return 1
    files: list[str] = []
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix in SKIP_SUFFIXES or path.name in SKIP_NAMES:
            continue
        rel = path.relative_to(root).as_posix()
        if rel.startswith(SKIP_DIRS):
            continue
        files.append("./" if rel == "index.html" else rel)
        digest.update(rel.encode())
        digest.update(path.read_bytes())
    # Les fichiers audio changent aussi la version (sans être préchargés).
    for path in sorted(root.rglob("*.mp3")):
        digest.update(path.relative_to(root).as_posix().encode())
        digest.update(str(path.stat().st_size).encode())
    version = digest.hexdigest()[:12]
    (root / "precache.json").write_text(json.dumps(files, ensure_ascii=False), encoding="utf-8")
    sw.write_text(sw.read_text(encoding="utf-8").replace("__LUMIERE_VERSION__", version), encoding="utf-8")
    size = sum((root / f).stat().st_size for f in files if f != "./") / 1e6
    print(f"{len(files)} fichiers préchargés ({size:.1f} Mo), version {version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
