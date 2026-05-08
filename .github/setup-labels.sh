#!/usr/bin/env bash
# =============================================================================
# Bonsai GBA — GitHub issue labels (idempotent)
# =============================================================================
#
# Wipes the default GitHub labels and (re)creates the curated set used by
# this repo. Safe to re-run any time; --force on `gh label create` means
# existing labels get updated rather than duplicated.
#
# Usage:
#   .github/setup-labels.sh                       # current repo (auto-detected)
#   .github/setup-labels.sh -R owner/repo         # explicit repo target
#
# Requires: `gh` (GitHub CLI), authenticated with `repo` scope.
# =============================================================================

set -euo pipefail

REPO_ARGS=("$@")

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: 'gh' (GitHub CLI) is not installed or not on PATH." >&2
    echo "       Install it from https://cli.github.com and run 'gh auth login'." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Default GitHub labels we want gone. Already-missing entries are ignored.
# -----------------------------------------------------------------------------
DEFAULT_LABELS=(
    "bug"
    "documentation"
    "duplicate"
    "enhancement"
    "good first issue"
    "help wanted"
    "invalid"
    "question"
    "wontfix"
)

echo "==> Removing default labels (if present)"
for label in "${DEFAULT_LABELS[@]}"; do
    if gh label delete "$label" --yes "${REPO_ARGS[@]}" >/dev/null 2>&1; then
        printf "    deleted: %s\n" "$label"
    fi
done

# -----------------------------------------------------------------------------
# Curated label set.
#
# Format:  name|hex-color|description
#
# Color palette (consistent so the label list reads as semantic blocks):
#   Bug severity ramp:  yellow → orange → red       (warm, demands attention)
#   Subsystem / area:   blue                         (neutral, just routing)
#   Type:               mint green                   (additive work)
#   Triage / status:    gray                         (waiting on humans)
#   Contributor invite: bright green                 (come on in)
# -----------------------------------------------------------------------------
LABELS=(
    # --- Bug categories ---
    "accuracy|f9c74f|Game runs but audio, graphics, or timing is subtly wrong"
    "performance|f3722c|Frame drops, stutter, or unexpected CPU/memory usage"
    "crash|d62828|Hard crash, freeze, or PSP BSOD"
    "memory-leak|9d0208|Memory or other resource use grows unbounded"
    "regression|7209b7|Was working in a previous build, now broken"

    # --- Subsystem / area ---
    "area: audio|2563eb|Sound output, mixing, sync"
    "area: video|2563eb|Renderer, blending, layers, color"
    "area: input|2563eb|Controls, mapping, turbo, deadzones"
    "area: dynarec|2563eb|Dynamic recompiler / CPU emulation"
    "area: gui|2563eb|Menu, settings, file browser"
    "area: overlay|2563eb|Bezel/border overlay system"
    "area: build|2563eb|Compilation, toolchain, CI"

    # --- Type ---
    "enhancement|a7f3d0|Feature request or quality-of-life improvement"

    # --- Triage / status ---
    "needs-repro|9ca3af|Cannot reproduce yet; reporter must provide repro steps"
    "needs-info|9ca3af|Waiting on more information from the reporter"
    "upstream|6b7280|Issue also exists in FrogGBA / TempGBA / gpSP upstream"

    # --- Contributor invitation ---
    "good-first-issue|22c55e|Small, well-scoped task, suitable for new contributors"
    "help-wanted|10b981|Maintainer welcomes outside contributions on this"
)

echo
echo "==> Creating / updating curated labels"
for entry in "${LABELS[@]}"; do
    IFS='|' read -r name color desc <<<"$entry"
    if gh label create "$name" \
            --color "$color" \
            --description "$desc" \
            --force \
            "${REPO_ARGS[@]}" >/dev/null; then
        printf "    ok: %s\n" "$name"
    fi
done

echo
echo "==> Final label set:"
gh label list "${REPO_ARGS[@]}"
