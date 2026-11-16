#!/usr/bin/env python3
"""Compose et synthétise la musique de Lumière (aucun son téléchargé).

Timbres d'inspiration ouest-africaine : kalimba (lamellophone), balafon
(xylophone de bois), petit shaker, nappes douces. Gamme pentatonique majeure.
Chaque morceau boucle sans coupure (les fins de notes reviennent au début).

Prérequis : numpy et ffmpeg. Depuis la racine du dépôt :
    python tools/music/generate.py
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np

RATE = 32000
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "audio" / "music"
rng = np.random.default_rng(11)

# Do majeur pentatonique : do, ré, mi, sol, la (sur plusieurs octaves).
PENTA = [0, 2, 4, 7, 9]


def midi(note: int) -> float:
    return 440.0 * 2 ** ((note - 69) / 12)


def degree(d: int, base: int = 60) -> int:
    """Degré de la gamme pentatonique (peut être négatif) → note MIDI."""
    octave, step = divmod(d, 5)
    return base + 12 * octave + PENTA[step]


def t(duration: float) -> np.ndarray:
    return np.arange(int(RATE * duration)) / RATE


def kalimba(freq: float, duration: float = 1.6, vel: float = 1.0) -> np.ndarray:
    x = t(duration)
    env = np.exp(-x * 3.2) * np.clip(x / 0.004, 0, 1)
    tone = np.sin(2 * np.pi * freq * x) + 0.18 * np.sin(2 * np.pi * freq * 5.4 * x) * np.exp(-x * 14)
    return tone * env * vel


def balafon(freq: float, duration: float = 0.7, vel: float = 1.0) -> np.ndarray:
    x = t(duration)
    env = np.exp(-x * 7) * np.clip(x / 0.002, 0, 1)
    tone = (np.sin(2 * np.pi * freq * x) + 0.35 * np.sin(2 * np.pi * freq * 2.76 * x) * np.exp(-x * 18)
            + 0.12 * np.sin(2 * np.pi * freq * 5.4 * x) * np.exp(-x * 30))
    # Le petit grésillement de la calebasse.
    buzz = rng.standard_normal(len(x)) * np.exp(-x * 40) * 0.08
    return (tone + buzz) * env * vel


def pad(freqs: list[float], duration: float, vel: float = 1.0) -> np.ndarray:
    x = t(duration)
    attack = np.clip(x / 0.8, 0, 1)
    release = np.clip((duration - x) / 0.8, 0, 1)
    tone = sum(np.sin(2 * np.pi * f * x) + 0.3 * np.sin(2 * np.pi * f * 2 * x + 0.5) for f in freqs) / len(freqs)
    trem = 1 + 0.08 * np.sin(2 * np.pi * 0.4 * x)
    return tone * attack * release * trem * vel


def shaker(duration: float = 0.09, vel: float = 1.0) -> np.ndarray:
    x = t(duration)
    noise = rng.standard_normal(len(x))
    noise = np.diff(np.concatenate([[0], noise]))  # aigus
    return noise * np.exp(-x * 45) * vel


def bass(freq: float, duration: float = 0.6, vel: float = 1.0) -> np.ndarray:
    x = t(duration)
    return np.sin(2 * np.pi * freq * x) * np.exp(-x * 4) * np.clip(x / 0.01, 0, 1) * vel


class Track:
    def __init__(self, bpm: int, bars: int):
        self.beat = 60 / bpm
        self.length = int(RATE * self.beat * 4 * bars)
        self.buf = np.zeros(self.length)

    def add(self, beat: float, sound: np.ndarray, gain: float = 1.0) -> None:
        start = int(beat * self.beat * RATE) % self.length
        end = start + len(sound)
        if end <= self.length:
            self.buf[start:end] += sound * gain
        else:  # La fin de la note revient au début : la boucle est parfaite.
            cut = self.length - start
            self.buf[start:] += sound[:cut] * gain
            self.buf[: end - self.length] += sound[cut:] * gain


# Accords en degrés : I, vi, IV, V (couleurs pentatoniques).
PROGRESSION = [[0, 2, 4], [-1, 1, 4], [-2, 0, 2], [-1, 1, 3]]


def melody(seed: int, bars: int, density: float) -> list[tuple[float, int]]:
    """Une mélodie qui se promène doucement dans la gamme."""
    r = np.random.default_rng(seed)
    notes = []
    d = 5
    for bar in range(bars):
        for step in range(8):
            if r.random() < density or step == 0:
                d = int(np.clip(d + r.choice([-2, -1, -1, 1, 1, 2, 0]), 2, 10))
                notes.append((bar * 4 + step * 0.5, d))
    return notes


def make(name: str) -> np.ndarray:
    if name == "home":
        tr = Track(80, 16)
        for bar in range(16):
            chord = PROGRESSION[bar % 4]
            tr.add(bar * 4, pad([midi(degree(c, 48)) for c in chord], tr.beat * 4.2), 0.32)
            for i, c in enumerate(chord + [chord[0] + 5]):
                tr.add(bar * 4 + i * 0.5 + (bar % 2) * 2, kalimba(midi(degree(c, 60))), 0.22)
        for beat, d in melody(3, 16, 0.35):
            tr.add(beat, kalimba(midi(degree(d, 60)), 2.0), 0.34)
    elif name == "map":
        tr = Track(96, 16)
        for bar in range(16):
            chord = PROGRESSION[bar % 4]
            tr.add(bar * 4, bass(midi(degree(chord[0], 36)), 0.9), 0.5)
            tr.add(bar * 4 + 2.5, bass(midi(degree(chord[0], 36)), 0.5), 0.35)
            for step in range(8):
                tr.add(bar * 4 + step * 0.5, shaker(vel=1.0 if step % 2 == 0 else 0.6), 0.06)
            tr.add(bar * 4, pad([midi(degree(c, 48)) for c in chord], tr.beat * 4.1), 0.18)
        for beat, d in melody(7, 16, 0.55):
            tr.add(beat, balafon(midi(degree(d, 60))), 0.32)
            tr.add(beat + 0.25, balafon(midi(degree(d, 60)), vel=0.35), 0.2)
    elif name == "story":
        tr = Track(66, 16)
        for bar in range(16):
            chord = PROGRESSION[bar % 4]
            tr.add(bar * 4, pad([midi(degree(c, 48)) for c in chord], tr.beat * 4.4), 0.34)
        for beat, d in melody(11, 16, 0.12):
            tr.add(beat, kalimba(midi(degree(d, 60)), 2.4, 0.8), 0.22)
    elif name == "games":
        tr = Track(112, 16)
        for bar in range(16):
            chord = PROGRESSION[bar % 4]
            for b in (0, 1.5, 2, 3.5):
                tr.add(bar * 4 + b, bass(midi(degree(chord[0], 36)), 0.4), 0.45)
            for step in range(8):
                tr.add(bar * 4 + step * 0.5, shaker(vel=1.0 if step % 2 == 1 else 0.5), 0.08)
            for i, c in enumerate(chord * 2):
                tr.add(bar * 4 + i * 0.5, kalimba(midi(degree(c, 72)), 0.8, 0.7), 0.14)
        for beat, d in melody(19, 16, 0.6):
            tr.add(beat, balafon(midi(degree(d, 60))), 0.3)
    else:
        raise ValueError(name)
    signal = tr.buf
    return signal / (np.max(np.abs(signal)) or 1) * 0.8


def write(name: str, signal: np.ndarray) -> None:
    pcm = (signal * 32767).astype(np.int16)
    with tempfile.TemporaryDirectory() as tmp:
        wav_path = Path(tmp) / "m.wav"
        with wave.open(str(wav_path), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(pcm.tobytes())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav_path), "-codec:a", "libmp3lame",
                        "-b:a", "56k", str(OUT / f"{name}.mp3")], check=True)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for name in ("home", "map", "story", "games"):
        signal = make(name)
        write(name, signal)
        print(f"  {name}.mp3 ({len(signal) / RATE:.0f} s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
