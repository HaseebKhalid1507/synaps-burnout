# synaps-burnout

```
╔══════════════════════════════════════════════════════════════════╗
║  QUICKHACK ▸ SYNAPSE BURNOUT           internal: BrainMeltProgram ║
║  CLASS      Combat quickhack  →  offensive agent-in-a-box         ║
║  UPLOAD     docker run         (you deploy it — you don't install)║
║  PAYLOAD    BlackArch toolkit + Synaps runtime (static musl)      ║
║  EFFECT     remote recon/intrusion, agent already on the wire     ║
╚══════════════════════════════════════════════════════════════════╝
```

> *Overloads the target's neural pathways until the mind cooks itself. Covert. Remote. Lethal.*

A self-contained **offensive-security agent-in-a-box**: BlackArch (Arch rolling) + a
curated bug-bounty / pentest CLI toolkit + the [Synaps](https://github.com/HaseebKhalid1507/SynapsCLI)
agent runtime baked in as a static musl binary. Spin it up anywhere, get a fully armed
recon environment with an autonomous agent already on the inside.

## The quickhack

In *Cyberpunk 2077*, **Synapse Burnout** (internal asset name `BrainMeltProgram`) is a
combat quickhack — an intrusion program you upload into a target's neural link that deals
damage scaling with the RAM you burn: **+10% per unit, up to +300%.** Higher tiers make it
*cheaper* (Tier 4: kills refund RAM) and *harder-hitting* (Tier 5: +100% under Overclock).

This is that, made real. The mapping isn't decoration — it's the design:

- **`synaps`** is the agent you deploy; **burnout** is what it does to the target.
- You don't `ssh` in and putter around a shell — you **deploy** it.
- The BlackArch tools are the payload; the agent rides the wire.
- **RAM scaling → profiles:** the more you load into the deck, the harder it hits — and
  the more it weighs (see *Loadout*).
- **Tiers → roadmap:** Tier 3 is the foundation that ships today. Tiers 4–5 are the
  operator, skills, and broker that make it *cheap and lethal* (see *Tier upgrades*).

---

## What's in the box

- **Base:** `blackarchlinux/blackarch:latest` — freshest tools, chosen because Synaps
  ships a static musl binary (base-agnostic; pacman-vs-dpkg is irrelevant).
- **Agent:** `synaps` on `PATH` — static musl build, zero dynamic deps.
- **Tools:** *curated CLI packages*, NOT `blackarch-*` groups. Groups drag in broken
  GUI tools (badkarma → webkit2gtk) and 128 tesseract OCR packs nobody wants headless.

## Compile the quickhack

```bash
./fetch-synaps.sh          # pull the Synaps musl binary into the build context (needs gh auth)
./build.sh minimal         # 5-tool smoke test  (~1.5 GB)
./build.sh bugbounty       # full recon/web rig  (~5.7 GB)   [default]
./build.sh pentest         # + exploitation / cracking / AD
./build.sh full            # the whole blackarch group (2800+, MAY BREAK on rolling)
```

Builds are heavy (BlackArch base + seclists + nuclei-templates). Run on a host with
disk headroom.

## Upload (run)

```bash
docker run -it --rm blackarch-synaps:bugbounty          # drops to a shell (entrypoint = bash)
```

## Configuring auth (deploy time)

The image bakes **no credentials.** You supply auth at `docker run` time — pick one lane.
Synaps resolves its credential source at runtime: if `SYNAPS_AUTH_ENDPOINT` is set it runs
in **broker mode** (fetches short-lived tokens, stores nothing); otherwise it uses a local
key from the environment.

```bash
cp .env.example .env      # then uncomment + fill ONE lane
docker run --env-file .env -it --rm blackarch-synaps:bugbounty
```

| Lane | Env | When |
|------|-----|------|
| **A. Anthropic key** | `ANTHROPIC_API_KEY` | simplest — static, isolated, revocable |
| **B. Local / OpenAI-compat** | `LOCAL_ENDPOINT` (+ `LOCAL_API_KEY`) | Ollama / vLLM / gateway; no cred leaves your net |
| **C. Broker (zero-cred)** | `SYNAPS_AUTH_ENDPOINT` + `SYNAPS_MACHINE_TOKEN` | **offensive use** — nothing to steal if the box gets popped |
| **D. Bring-your-own dir** | mount + `SYNAPS_BASE_DIR` | advanced; you own the blast-radius call |

> ⚠️ **Don't mount your primary OAuth `auth.json` into an offensive container.** If a tool
> gets popped by a hostile target, your Anthropic account goes with it. Use a scoped key (A)
> or the broker (C) — that's the whole point of running recon in a container.

## Loadout (profiles)

Like the quickhack, damage scales with what you burn — bigger loadout hits harder, weighs more.

| Profile     | "RAM" | Tools                                                                 |
|-------------|-------|-----------------------------------------------------------------------|
| `minimal`   | ~1.5 GB | nmap, subfinder, httpx, nuclei, ffuf                                 |
| `bugbounty` | ~5.7 GB | + amass, dnsx, naabu, gau, feroxbuster, gobuster, wpscan, sqlmap, nikto, masscan, rustscan, seclists, nuclei-templates … |
| `pentest`   | heavier | + metasploit, hydra, john, hashcat, crackmapexec, impacket, evil-winrm, enum4linux-ng, chisel |
| `full`      | huge  | the entire `blackarch` group                                          |

## Gotchas (learned the hard way, S239)

- **`httpx` → `httpx-pd`.** BlackArch packages ProjectDiscovery's httpx as `httpx-pd`
  to avoid the python-httpx collision. The Dockerfile symlinks `httpx` back for you.
- **`katana` is not packaged** in BlackArch — dropped from the curated list. `go install` it if needed.
- **Groups are fragile on rolling** — one unsatisfiable dep aborts the whole build.
  Curated package lists sidestep this. That's why `full` carries a "may break" warning.

## Status — Tier 3 (foundation), S239 (2026-07-08)

Foundation **built + verified**. `minimal` (1.46 GB) and `bugbounty` (5.74 GB) both
build clean; `synaps 0.5.1` runs inside; all tools spot-checked live.

## Tier upgrades (roadmap)

Tier 3 is the quickhack that fires. Tiers 4–5 make it *cheap and lethal* — the operator, not just the deck:

- [ ] **Entrypoint** — boot into `synaps` (container *is* the agent) vs. shell.
- [x] **Credentials** — deploy-time auth config (env-driven, 4 lanes incl. zero-cred broker). See *Configuring auth*.
- [ ] **Persistence** — mount `/work` so scope/loot survives the container.
- [ ] **Operator persona** — Synaps that boots knowing the tools on its PATH.
- [ ] **Skills / playbooks** — encoded recon pipeline (subfinder → httpx → nuclei → ffuf).
