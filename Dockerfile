# BlackArch + Synaps — self-contained bug-bounty / pentest rig
# ---------------------------------------------------------------
# Base : BlackArch (Arch rolling) — freshest tools.
# Agent: Synaps rides in as a STATIC musl binary (zero dynamic deps,
#        base-agnostic — pacman-vs-dpkg is irrelevant).
# Tools: CURATED CLI package lists (NOT blackarch-* groups). Groups
#        drag in GUI tools (badkarma→webkit2gtk) that break on rolling
#        and 128 tesseract OCR packs nobody wants in a headless box.
#        Selectable at BUILD TIME via the TOOLS arg. Use build.sh for
#        named profiles.
#
#   docker build -t blackarch-synaps .           # curated bugbounty default
#   ./build.sh minimal                            # 5-tool smoke test
#   ./build.sh pentest                            # + exploitation/cracking
#   ./build.sh full                               # the whole blackarch group (may break)
# ---------------------------------------------------------------
FROM blackarchlinux/blackarch:latest

# ---- tool loadout (curated CLI packages, verified to exist) ----
ARG TOOLS="subfinder amass assetfinder findomain dnsx naabu httpx httprobe gau waybackurls ffuf wfuzz gobuster feroxbuster dirb nikto whatweb wafw00f wpscan sqlmap nmap masscan rustscan nuclei nuclei-templates seclists jq ripgrep"

# Refresh keyrings first (rolling base drifts), full system upgrade + install the
# curated tools in ONE transaction (Arch hates partial upgrades), then nuke the
# cache to stay lean. --noconfirm auto-picks default providers.
RUN pacman -Sy --noconfirm --needed archlinux-keyring blackarch-keyring \
 && pacman -Syu --noconfirm --needed ${TOOLS} \
 && yes | pacman -Scc

# ---- ergonomics: reclaim expected tool names ----
# BlackArch ships ProjectDiscovery's httpx as `httpx-pd` (avoids the python-httpx
# collision). Every bug-bounty writeup calls it `httpx`, so alias it back.
RUN [ -e /usr/bin/httpx-pd ] && ln -sf /usr/bin/httpx-pd /usr/local/bin/httpx || true

# ---- Synaps (static musl, copied from build context) ----
# SynapsCLI is a private repo, so we pre-fetch the release asset on the host and
# COPY it in — no GH token ever touches the image or its layers.
COPY synaps /usr/local/bin/synaps
RUN chmod 755 /usr/local/bin/synaps && synaps --version

# ---- entrypoint: the container boots into Synaps (the agent) ----
# Default = launch synaps. `docker run <img> shell` drops to a raw shell.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
WORKDIR /work
ENV TERM=xterm-256color
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
