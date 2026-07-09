# synaps-burnout

**A self-contained offensive-security agent-in-a-box.** BlackArch (Arch rolling)
+ a curated bug-bounty / pentest CLI toolkit + the [Synaps](https://github.com/HaseebKhalid1507/SynapsCLI)
agent runtime baked in as a static musl binary. Spin it up anywhere, get a fully
armed recon environment with an autonomous agent already on the inside.

> Reboot of the name — the old `synaps-burnout` (a Svelte web GUI for Synaps) is
> archived at `~/Projects/synaps-burnout-svelte-archived`. This is the new Burnout.

---

## What's in the box

- **Base:** `blackarchlinux/blackarch:latest` — freshest tools, chosen because Synaps
  ships a static musl binary (base-agnostic; pacman-vs-dpkg is irrelevant).
- **Agent:** `synaps` on `PATH` — static musl build, zero dynamic deps.
- **Tools:** *curated CLI packages*, NOT `blackarch-*` groups. Groups drag in broken
  GUI tools (badkarma → webkit2gtk) and 128 tesseract OCR packs nobody wants headless.

## Build

```bash
./fetch-synaps.sh          # pull the Synaps musl binary into the build context (needs gh auth)
./build.sh minimal         # 5-tool smoke test  (~1.5 GB)
./build.sh bugbounty       # full recon/web rig  (~5.7 GB)   [default]
./build.sh pentest         # + exploitation / cracking / AD
./build.sh full            # the whole blackarch group (2800+, MAY BREAK on rolling)
```

Builds are heavy (BlackArch base + seclists + nuclei-templates). Run on a host with
disk headroom — currently **Avante**, not jade.

## Run

```bash
docker run -it --rm blackarch-synaps:bugbounty          # drops to a shell (entrypoint = bash)
```

## Profiles

| Profile     | Tools                                                                 |
|-------------|-----------------------------------------------------------------------|
| `minimal`   | nmap, subfinder, httpx, nuclei, ffuf                                   |
| `bugbounty` | + amass, dnsx, naabu, gau, feroxbuster, gobuster, wpscan, sqlmap, nikto, masscan, rustscan, seclists, nuclei-templates … |
| `pentest`   | + metasploit, hydra, john, hashcat, crackmapexec, impacket, evil-winrm, enum4linux-ng, chisel |
| `full`      | the entire `blackarch` group                                          |

## Gotchas (learned the hard way, S239)

- **`httpx` → `httpx-pd`.** BlackArch packages ProjectDiscovery's httpx as `httpx-pd`
  to avoid the python-httpx collision. The Dockerfile symlinks `httpx` back for you.
- **`katana` is not packaged** in BlackArch — dropped from the curated list. `go install` it if needed.
- **Groups are fragile on rolling** — one unsatisfiable dep aborts the whole build.
  Curated package lists sidestep this. That's why `full` carries a "may break" warning.

## Status — S239 (2026-07-08)

Foundation **built + verified**. `minimal` (1.46 GB) and `bugbounty` (5.74 GB) both
build clean; `synaps 0.5.1` runs inside; all tools spot-checked live.

## Roadmap — beyond the foundation

The box is the body; the operator is the point. Not built yet:

- [ ] **Entrypoint** — boot into `synaps` (container *is* the agent) vs. shell.
- [ ] **Credentials** — how Synaps authenticates inside the box (an agent with no key is inert).
- [ ] **Persistence** — mount `/work` so scope/loot survives the container.
- [ ] **Operator persona** — Synaps that boots knowing the tools on its PATH.
- [ ] **Skills / playbooks** — encoded recon pipeline (subfinder → httpx → nuclei → ffuf).
