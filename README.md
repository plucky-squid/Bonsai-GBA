# Bonsai GBA

A lean, performance-focused Game Boy Advance emulator for the PlayStation Portable.

Bonsai GBA is forked from [FrogGBA](https://github.com/tzubertowski/FrogGBA),
which is itself based on TempGBA4PSP and the legendary gameplaySP kai. The
goal of this fork is a focused optimisation pass: stripping out debug noise,
properly utilising the PSP's RAM and Media Engine, and tightening the dynamic
recompiler.

> ⚠️ **Status:** active development, no stable release yet. Expect breakage.

---

## Why Bonsai GBA?

FrogGBA is already the best GBA emulator on PSP — but it's still leaving
performance on the table. This fork exists to fix that:

- **Speed first.** Remove redundant `printf`/log calls scattered across the
  hot path. They're cheap on a desktop, expensive on a 333 MHz MIPS chip.
- **Better memory utilisation.** Move the right caches into volatile RAM,
  align hot structures to cache lines, and reclaim the ~550 KB of static
  allocations that should be dynamic.
- **Use the Media Engine.** The PSP has a second 333 MHz CPU sitting mostly
  idle during emulation. Audio mixing and parts of the renderer can move
  there.
- **Code cleanliness.** Trim dead code paths, document non-obvious
  invariants, replace magic numbers with named constants.
- **Continuous integration.** Every push is compiled in a known-good
  `pspdev` toolchain (see [`.github/workflows/`](.github/workflows/)) so
  we don't ship a build that only worked on one developer's laptop.

If you just want to play GBA games on your PSP today, use FrogGBA — it's
stable. If you want the squeezed-every-cycle version, watch this repo.

---

## Installation

Custom firmware (CFW) is required, same as any PSP homebrew.

1. Build or download an `EBOOT.PBP` (see below — no pre-built releases yet).
2. Copy it to `PSP/GAME/BonsaiGBA/EBOOT.PBP` on your memory stick.
3. Launch from the PSP's **Game** menu.

Optional: drop `.ovl` overlay files into `PSP/GAME/BonsaiGBA/overlays/`
to enable custom borders and bezels.

---

## Build Instructions

The canonical build uses the official `pspdev` Docker image, so the steps
are identical across host operating systems and the toolchain version is
pinned.

### Prerequisites

- [Docker](https://www.docker.com/) — Docker Desktop on macOS/Windows,
  or Docker Engine on Linux.
- ~2 GB of free disk space for the toolchain image (first build only).

### macOS / Linux

```bash
git clone https://github.com/plucky-squid/Bonsai-GBA.git
cd Bonsai-GBA
docker compose up --build
```

The compiled `EBOOT.PBP` and `.prx` will be written to `build/`.

### Windows

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
(the WSL 2 backend is recommended for speed). Then, from PowerShell:

```powershell
git clone https://github.com/plucky-squid/Bonsai-GBA.git
cd Bonsai-GBA
docker compose up --build
```

The build output appears in the `build\` folder.

### Manual build (no Docker)

If you already have the `pspdev` toolchain (`psp-gcc`, `psp-config`,
PSPSDK) on your `PATH`:

```bash
cd source
make clean
make
```

Building the toolchain from source is a 30–60 minute affair — the Docker
path is recommended unless you're actively hacking on the toolchain
itself.

---

## Legal Disclaimer

Bonsai GBA is an emulator. **No copyrighted ROMs, BIOS files, or any
other Nintendo intellectual property are bundled with this project.**
You are solely responsible for legally obtaining any software you run on
the emulator — typically by dumping ROMs from cartridges you personally
own.

Bonsai GBA is licensed under the **GNU General Public License, version 2
or later**. See [LICENSE](LICENSE) for the full text and the chain of
attribution back to the original gameplaySP, TempGBA, TempGBA4PSP, and
FrogGBA authors.

This project is **not** affiliated with, endorsed by, or sponsored by
Nintendo, Sony, or any other rights holder. "Game Boy Advance" and
"PlayStation Portable" are trademarks of their respective owners and are
used here for descriptive purposes only.

---

## Features (Inherited from FrogGBA)

These already work because they came across in the fork. Bonsai-specific
improvements will be tracked in a `CHANGELOG.md` once the first release
is cut.

- **Overlay system** — render PNG bezels/borders above the game window.
  Use the [FrogGBA overlay generator](https://froggba.onrender.com) to
  convert 480×272 PNGs to `.ovl` format, then drop them in
  `PSP/GAME/BonsaiGBA/overlays/`.
- **Aspect ratios:** Core (3:2), Zoom (fills vertically, slight crop),
  Stretch (full 480×272).
- **Color correction:** GPSP, Retro, or Off.
- **Recent games menu** — your last 10 played titles surface at the top
  of the file list.
- **Save states** with file validation and persistent settings.
- **Fast forward** (SELECT + R) and turbo buttons (Triangle / Square).
- **FPS overlay** (SELECT + Square).
- **Volatile memory support** — extra PSP RAM used on all PSP models
  (1000/2000/3000/Go).

---

## Contributing

Issues and PRs are welcome. Please target the `calamari` branch for now.

The issue tracker uses labels tailored to emulator development:

- `accuracy` — game runs but audio/graphics are subtly wrong
- `performance` — frame drops or unexpected CPU usage
- `memory-leak` — anything that grows unbounded over time
- `good-first-issue` — small, well-scoped tasks for new contributors

If you're investigating a slow game, please attach: the ROM title (no
ROM file!), the scene/area where the slowdown occurs, your PSP model,
and ideally a short video or before/after FPS reading.

---

## Acknowledgments

Bonsai GBA stands on the shoulders of a long chain of work:

- **Exophase** — original gameplaySP (2006)
- **takka** — gameplaySP kai improvements (2007)
- **Nebuleon, Normmatt, BassAceGold** — TempGBA
- The **TempGBA4PSP community** — PSP-specific enhancements
- The **FrogGBA Project** — modernised emulator and overlay system
- Everyone who has filed bugs, sent patches, or tested builds.

See [LICENSE](LICENSE) for the full attribution and GPL v2+ details.
