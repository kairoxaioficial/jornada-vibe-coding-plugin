#!/bin/bash
# Atalho para o script real, que vive junto do skill.
exec bash "$(cd "$(dirname "$0")/.." && pwd)/skills/jornada-vibe-coding/scripts/instalar-ferramentas.sh" "$@"
