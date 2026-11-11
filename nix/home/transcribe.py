"""Label whisper words with speakers (sherpa-onnx diarization) and write a transcript."""

import argparse
import json
import sys

import numpy as np
import sherpa_onnx
import soundfile as sf

p = argparse.ArgumentParser()
p.add_argument("--whisper-json", required=True)
p.add_argument("--wav", help="16 kHz mono wav; omit to skip speaker labels")
p.add_argument("--segmentation", required=True)
p.add_argument("--embedding", required=True)
p.add_argument("--speakers", type=int, default=-1, help="known speaker count")
p.add_argument("--threshold", type=float, default=0.5)
p.add_argument("--out", required=True)
a = p.parse_args()


def ts(t):
    t = int(t)
    return f"{t // 3600:02d}:{t % 3600 // 60:02d}:{t % 60:02d}"


def diarize():
    config = sherpa_onnx.OfflineSpeakerDiarizationConfig(
        segmentation=sherpa_onnx.OfflineSpeakerSegmentationModelConfig(
            pyannote=sherpa_onnx.OfflineSpeakerSegmentationPyannoteModelConfig(model=a.segmentation),
            num_threads=8,
        ),
        embedding=sherpa_onnx.SpeakerEmbeddingExtractorConfig(model=a.embedding, num_threads=8),
        clustering=sherpa_onnx.FastClusteringConfig(num_clusters=a.speakers, threshold=a.threshold),
        min_duration_on=0.3,
        min_duration_off=0.5,
    )
    if not config.validate():
        sys.exit("transcribe: invalid diarization config")
    sd = sherpa_onnx.OfflineSpeakerDiarization(config)
    audio, sr = sf.read(a.wav, dtype="float32", always_2d=True)
    if sr != sd.sample_rate:
        sys.exit(f"transcribe: expected {sd.sample_rate} Hz audio, got {sr}")

    def progress(done, total):
        print(f"\rspeakers: {100 * done // total}%", end="", file=sys.stderr, flush=True)
        return 0

    result = sd.process(audio[:, 0], callback=progress).sort_by_start_time()
    print(file=sys.stderr)
    return [(r.start, r.end, r.speaker) for r in result]


def speaker_at(segs, start, end):
    best, best_overlap, nearest, nearest_gap = None, 0.0, None, float("inf")
    for s, e, spk in segs:
        overlap = min(end, e) - max(start, s)
        if overlap > best_overlap:
            best, best_overlap = spk, overlap
        gap = max(s - end, start - e, 0)
        if gap < nearest_gap:
            nearest, nearest_gap = spk, gap
    return best if best is not None else nearest


data = json.load(open(a.whisper_json))
segs = diarize() if a.wav else []

lines = []  # [speaker, start, text]
for seg in data["segments"]:
    words = seg.get("words") or [{"word": seg["text"], "start": seg["start"], "end": seg["end"]}]
    for w in words:
        spk = speaker_at(segs, w["start"], w["end"]) if segs else None
        if lines and lines[-1][0] == spk and (spk is not None or not w["word"].startswith(" ") or len(lines[-1][2]) < 400):
            lines[-1][2] += w["word"]
        else:
            lines.append([spk, w["start"], w["word"]])

# Renumber speakers by first appearance.
order = {}
for spk, _, _ in lines:
    if spk is not None and spk not in order:
        order[spk] = len(order) + 1

with open(a.out, "w") as f:
    for spk, start, text in lines:
        label = f" Speaker {order[spk]}:" if spk is not None else ""
        f.write(f"[{ts(start)}]{label} {text.strip()}\n\n")

if segs:
    print(f"{len(order)} speakers detected", file=sys.stderr)
