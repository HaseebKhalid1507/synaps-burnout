#!/usr/bin/env bash
# build.sh — build the BlackArch + Synaps rig with a named tool profile.
#
#   ./build.sh                  # default: bugbounty profile
#   ./build.sh minimal          # 5-tool smoke test (smallest, fastest)
#   ./build.sh bugbounty        # full curated recon/web bug-bounty rig
#   ./build.sh pentest          # bugbounty + exploitation, cracking, AD
#   ./build.sh full             # the whole blackarch group (2800+, MAY BREAK on rolling)
#   ./build.sh bugbounty my:tag # custom image tag
#
# Profiles are CURATED CLI package lists (verified to exist), not blackarch-*
# groups — groups drag in broken GUI tools + OCR bloat and abort the build.
set -euo pipefail

# --- shared tool blocks ---
RECON="subfinder amass assetfinder findomain dnsx naabu httpx httprobe gau waybackurls"
FUZZ="ffuf wfuzz gobuster feroxbuster dirb"
WEBSCAN="nikto whatweb wafw00f wpscan sqlmap"
PORTSCAN="nmap masscan rustscan"
VULN="nuclei nuclei-templates"
WORDLISTS="seclists"
UTILS="jq ripgrep"
EXPLOIT="metasploit hydra john hashcat medusa crackmapexec impacket enum4linux-ng smbmap evil-winrm chisel"

PROFILE="${1:-bugbounty}"
TAG="${2:-blackarch-synaps:${PROFILE}}"

case "$PROFILE" in
  minimal)   TOOLS="nmap subfinder httpx nuclei ffuf" ;;
  bugbounty) TOOLS="$RECON $FUZZ $WEBSCAN $PORTSCAN $VULN $WORDLISTS $UTILS" ;;
  pentest)   TOOLS="$RECON $FUZZ $WEBSCAN $PORTSCAN $VULN $WORDLISTS $UTILS $EXPLOIT" ;;
  full)      TOOLS="blackarch" ;;
  *) echo "unknown profile: '$PROFILE'  (choose: minimal | bugbounty | pentest | full)"; exit 1 ;;
esac

echo ">> profile : $PROFILE"
echo ">> tag     : $TAG"
echo ">> tools   : $TOOLS"
echo
docker build --build-arg TOOLS="$TOOLS" -t "$TAG" .
echo
echo ">> done. run it:  docker run -it --rm $TAG"
