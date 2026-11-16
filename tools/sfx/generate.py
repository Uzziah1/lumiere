#!/usr/bin/env python3
"""Fabrique les bruitages de Lumière par synthèse (aucun son téléchargé).

Sons doux et ronds, pensés pour les enfants : jamais d'alarme ni de buzzer.
Prérequis : numpy et ffmpeg. Depuis la racine du dépôt :
    python tools/sfx/generate.py
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np

RATE = 44100
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "audio" / "sfx"
rng = np.random.default_rng(7)


def t(duration: float) -> np.ndarray:
    return np.arange(int(RATE * duration)) / RATE


def env(duration: float, attack: float = 0.005, decay: float = 8.0) -> np.ndarray:
    x = t(duration)
    a = np.clip(x / attack, 0, 1)
    return a * np.exp(-x * decay)


def bell(freq: float, duration: float, decay: float = 5.0) -> np.ndarray:
    """Note de clochette : fondamentale + partiels doux."""
    x = t(duration)
    tone = (np.sin(2 * np.pi * freq * x) + 0.35 * np.sin(2 * np.pi * freq * 2.01 * x)
            + 0.12 * np.sin(2 * np.pi * freq * 3.02 * x))
    return tone * env(duration, 0.004, decay)


def lowpass(signal: np.ndarray, cutoff: np.ndarray | float) -> np.ndarray:
    """Filtre passe-bas à un pôle, fréquence de coupure variable."""
    cutoff = np.broadcast_to(np.asarray(cutoff, dtype=float), signal.shape)
    alpha = 1 - np.exp(-2 * np.pi * cutoff / RATE)
    out = np.empty_like(signal)
    y = 0.0
    for i, (s, a) in enumerate(zip(signal, alpha)):
        y += a * (s - y)
        out[i] = y
    return out


def mix(*parts: tuple[float, np.ndarray]) -> np.ndarray:
    length = max(int(start * RATE) + len(p) for start, p in parts)
    out = np.zeros(length)
    for start, p in parts:
        i = int(start * RATE)
        out[i:i + len(p)] += p
    return out


def sounds() -> dict[str, np.ndarray]:
    s: dict[str, np.ndarray] = {}
    # Toucher : petit « tic » feutré.
    s["tap"] = np.sin(2 * np.pi * 1100 * t(0.05)) * env(0.05, 0.002, 70) * 0.6
    # Pop : bulle qui éclate (glissando montant).
    x = t(0.11)
    freq = 380 + 700 * (x / x[-1]) ** 0.6
    s["pop"] = np.sin(2 * np.pi * np.cumsum(freq) / RATE) * env(0.11, 0.003, 30)
    # Réussite : arpège do-mi-sol-do.
    s["success"] = mix(*[(i * 0.085, bell(f, 0.6, 6) * (0.9 - i * 0.1)) for i, f in enumerate([523.3, 659.3, 784.0, 1046.5])])
    # Étoile : pluie de petites notes aiguës.
    notes = [1568, 1760, 2093, 2349, 2637, 3136]
    s["star"] = mix(*[(i * 0.055, bell(f, 0.5, 9) * 0.45) for i, f in enumerate(notes)])
    # Carte retournée : souffle court.
    noise = rng.standard_normal(int(RATE * 0.14))
    s["flip"] = lowpass(noise, np.linspace(5000, 900, len(noise))) * env(0.14, 0.01, 25) * 0.9
    # Pas tout à fait : deux « boup » descendants, très doux.
    s["wrong"] = mix((0, np.sin(2 * np.pi * 330 * t(0.16)) * env(0.16, 0.01, 18) * 0.5),
                     (0.13, np.sin(2 * np.pi * 262 * t(0.22)) * env(0.22, 0.01, 14) * 0.5))
    # Coup de marteau sur le bois.
    knock_noise = lowpass(rng.standard_normal(int(RATE * 0.12)), 1800) * env(0.12, 0.001, 45)
    knock_tone = np.sin(2 * np.pi * 190 * t(0.12)) * env(0.12, 0.001, 30)
    s["knock"] = (knock_noise * 1.6 + knock_tone) * 0.8
    # Envol / vague : souffle qui monte puis retombe.
    n = int(RATE * 0.6)
    shape = np.sin(np.linspace(0, np.pi, n)) ** 2
    s["whoosh"] = lowpass(rng.standard_normal(n), 300 + 2200 * shape) * shape * 0.9
    # Clochette.
    s["chime"] = mix((0, bell(880, 1.0, 4) * 0.7), (0.0, bell(1318.5, 0.8, 5) * 0.25))
    return s


def write(name: str, signal: np.ndarray) -> None:
    peak = np.max(np.abs(signal)) or 1
    pcm = (signal / peak * 0.85 * 32767).astype(np.int16)
    with tempfile.TemporaryDirectory() as tmp:
        wav_path = Path(tmp) / "s.wav"
        with wave.open(str(wav_path), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(pcm.tobytes())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav_path), "-codec:a", "libmp3lame",
                        "-b:a", "64k", str(OUT / f"{name}.mp3")], check=True)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, signal in sounds().items():
        write(name, signal)
        print(f"  {name}.mp3")
    return 0


if __name__ == "__main__":
    sys.exit(main())
