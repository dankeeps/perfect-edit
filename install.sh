#!/bin/zsh
# Instala o Perfect Cut como skill do Claude Code: .venv com faster-whisper (Whisper + VAD Silero)
# e um atalho em ~/.claude/skills/perfect-cut. Precisa de python3 >= 3.10 e ffmpeg (brew install ffmpeg).
set -e
AQUI="$(cd "$(dirname "$0")" && pwd)"
PY=$(command -v python3.12 || command -v python3.11 || command -v python3.10 || command -v python3)
"$PY" -m venv "$AQUI/.venv"
"$AQUI/.venv/bin/pip" install -q --upgrade pip
"$AQUI/.venv/bin/pip" install -q -r "$AQUI/requirements.txt"
command -v ffmpeg >/dev/null || echo "atenção: instale o ffmpeg (brew install ffmpeg)"
mkdir -p ~/.claude/skills
[ -e ~/.claude/skills/perfect-cut ] || ln -s "$AQUI" ~/.claude/skills/perfect-cut
echo "Perfect Cut instalado. No Claude Code: /perfect-cut"
