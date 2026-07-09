#!/usr/bin/env bash
# entrypoint.sh — the container IS the quickhack. It boots into Synaps.
#
#   docker run -it --rm --env-file .env <img>            # launch the agent (default)
#   docker run -it --rm <img> shell                      # drop to a raw shell instead
#   docker run --rm <img> --version                      # args pass straight to synaps
#
set -e

# Escape hatch — a plain shell for driving the tools by hand.
case "${1:-}" in
  shell|bash) shift; exec /bin/bash "$@" ;;
  sh)         shift; exec /bin/sh   "$@" ;;
esac

# No args + no TTY → the agent has nothing to attach to. Nudge, don't block.
if [ "$#" -eq 0 ] && [ ! -t 0 ]; then
  echo "synaps-burnout: the agent needs a TTY — run with 'docker run -it'." >&2
  echo "               (or 'docker run -it <img> shell' for a raw shell)"    >&2
fi

# Everything else → Synaps. No args = launch the agent; args pass through.
exec synaps "$@"
