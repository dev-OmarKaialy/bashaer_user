#!/usr/bin/env python3
"""Generates the original quiz/app SFX WAV files into assets/sounds/.

Pure stdlib (wave/math/random/struct), no third-party dependencies.

  tick.wav         - bright two-note "correct" chime (E5 -> A5)
  warning.wav      - low two-beep descending "wrong" warning
  countdown.wav    - single short beep for each start-light stage
  go.wav           - rising "GO" chime for the green light
  engine_start.wav - car ignition crank + settling idle rumble
  fireworks.wav    - celebratory popping firework bursts
"""
from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def _tone(freq: float, duration: float, shape: str = "sine", volume: float = 0.5) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    attack = max(1, int(0.004 * SAMPLE_RATE))
    release = max(1, int(0.03 * SAMPLE_RATE))
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        if shape == "sine":
            sample = math.sin(2 * math.pi * freq * t)
        elif shape == "triangle":
            phase = (freq * t) % 1.0
            sample = 4 * abs(phase - 0.5) - 1
        else:
            raise ValueError(f"unknown shape {shape}")
        env = 1.0
        if i < attack:
            env = i / attack
        if i >= n - release:
            env = max(0.0, (n - i) / release)
        out.append(sample * env * volume)
    return out


def _glide(freq_from: float, freq_to: float, duration: float, shape: str, volume: float) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    attack = max(1, int(0.005 * SAMPLE_RATE))
    release = max(1, int(0.04 * SAMPLE_RATE))
    out: list[float] = []
    phase = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = freq_from + (freq_to - freq_from) * (t / duration)
        phase += freq / SAMPLE_RATE
        if shape == "triangle":
            p = phase % 1.0
            sample = 4 * abs(p - 0.5) - 1
        else:
            sample = math.sin(2 * math.pi * phase)
        env = 1.0
        if i < attack:
            env = i / attack
        if i >= n - release:
            env = max(0.0, (n - i) / release)
        out.append(sample * env * volume)
    return out


def _silence(duration: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * duration)


def _finalize(samples: list[float], path: Path) -> None:
    out_dir = path.parent
    out_dir.mkdir(parents=True, exist_ok=True)
    peak = max(1.0, max(abs(s) for s in samples))
    frames = bytearray()
    for s in samples:
        frames += struct.pack("<h", int((s / peak) * 32000))
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(bytes(frames))
    print(f"wrote {path} ({len(samples) / SAMPLE_RATE:.2f}s)")


def build_tick() -> list[float]:
    note = _tone(659.25, 0.10, volume=0.5)  # E5
    pad = _silence(0.012)
    note2 = _tone(880.0, 0.16, volume=0.5)  # A5
    return note + pad + note2 + _silence(0.03)


def build_warning() -> list[float]:
    beep1 = _glide(330.0, 220.0, 0.18, shape="triangle", volume=0.42)
    gap = _silence(0.05)
    beep2 = _glide(330.0, 220.0, 0.18, shape="triangle", volume=0.42)
    return beep1 + gap + beep2 + _silence(0.04)


def build_countdown() -> list[float]:
    beep = _tone(880.0, 0.12, volume=0.45)
    end = len(beep)
    for i in range(int(SAMPLE_RATE * 0.05)):
        beep[end - 1 - i] *= max(0.0, 1.0 - i / (SAMPLE_RATE * 0.05))
    return beep


def build_go() -> list[float]:
    glide = _glide(420.0, 840.0, 0.28, shape="sine", volume=0.5)
    shimmer = _tone(840.0, 0.2, volume=0.12)
    shimmer_off = int(SAMPLE_RATE * 0.05)
    for i in range(shimmer_off):
        shimmer[i] *= 0.0
        shimmer[len(shimmer) - 1 - i] *= i / shimmer_off if i < shimmer_off else 0.0
    merged = [a + b for a, b in zip(glide, shimmer)]
    return merged + _silence(0.03)


def build_engine_start() -> list[float]:
    rng = random.Random(20260923)
    out: list[float] = []

    # Starter crank: a few low turnover thuds.
    for _ in range(9):
        thud = _tone(75.0, 0.045, volume=0.5)
        thud_n = len(thud)
        for i in range(thud_n):
            thud[i] *= math.exp(-4 * i / thud_n)
        out += thud
        out += _silence(0.02)
    out += _silence(0.08)

    # Settling idle rumble: filtered noise + low hum, then easing out.
    idle_n = int(SAMPLE_RATE * 0.9)
    noise = 0.0
    for i in range(idle_n):
        noise = 0.98 * noise + (rng.random() - 0.5) * 0.02
        t = i / SAMPLE_RATE
        hum = math.sin(2 * math.pi * 55 * t)
        settle = 0.55 + 0.45 * math.exp(-6 * t)
        am = 0.8 + 0.2 * math.sin(2 * math.pi * 31 * t)
        end = idle_n - i
        fade = 1.0 if end > int(0.15 * SAMPLE_RATE) else max(0.0, end / (0.15 * SAMPLE_RATE))
        out.append((noise * 0.7 + hum * 0.12) * settle * am * 0.5 * fade)
    return out + _silence(0.05)


def build_fireworks() -> list[float]:
    rng = random.Random(777)
    total = int(SAMPLE_RATE * 2.4)
    out = [0.0] * total

    def add(sample: float, index: int) -> None:
        if 0 <= index < total:
            out[index] += sample

    # Big bursting pops: short noise burst + low thump.
    for _ in range(8):
        at = int(rng.random() * total * 0.8)
        dur = int(SAMPLE_RATE * (0.07 + rng.random() * 0.05))
        amplitude = 0.4
        for i in range(dur):
            t = i / SAMPLE_RATE
            env = math.exp(-6 * i / dur)
            noise = (rng.random() - 0.5) * 2 * amplitude * env
            thump = math.sin(2 * math.pi * 90 * t) * 0.3 * amplitude * env
            add(noise + thump, at + i)

    # Crackling finale between the bursts.
    for _ in range(46):
        at = int(rng.random() * total)
        for i in range(int(SAMPLE_RATE * 0.008)):
            env = 1 - i / (SAMPLE_RATE * 0.008)
            add((rng.random() - 0.5) * 0.16 * env, at + i)
    return out


def main() -> None:
    _finalize(build_tick(), OUT_DIR / "tick.wav")
    _finalize(build_warning(), OUT_DIR / "warning.wav")
    _finalize(build_countdown(), OUT_DIR / "countdown.wav")
    _finalize(build_go(), OUT_DIR / "go.wav")
    _finalize(build_engine_start(), OUT_DIR / "engine_start.wav")
    _finalize(build_fireworks(), OUT_DIR / "fireworks.wav")


if __name__ == "__main__":
    main()