#!/usr/bin/env bash
# =============================================================================
# Bonsai GBA — GitHub branch protection (rulesets, idempotent)
# =============================================================================
#
# Configures a repository ruleset that gates the default branch (master)
# behind a green CI build. After this runs:
#
#   * No direct pushes to master. All changes go through a pull request.
#   * Force-pushes to master are blocked.
#   * Deleting master is blocked.
#   * The "PSP build (pspdev toolchain)" check from .github/workflows/build.yml
#     must succeed before a PR can be merged.
#   * Branch must be up to date with master at merge time, so CI ran on the
#     actual post-merge state, not a stale base.
#   * 0 approvals required (one-developer-friendly), but the merge must
#     still be performed through the PR UI.
#   * Repo admins can bypass for emergency cases.
#
# Idempotent: re-running this updates the existing ruleset in place.
# Source of truth lives here; UI edits should be back-ported.
#
# Usage:
#   .github/setup-rulesets.sh                       # current repo (auto-detected)
#   .github/setup-rulesets.sh owner/repo            # explicit target
#
# Requires: `gh` (GitHub CLI), authenticated with `repo` scope, admin on repo.
# =============================================================================

set -euo pipefail

REPO="${1:-}"
if [ -z "$REPO" ]; then
    REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
fi
RULESET_NAME="Default branch CI gate"

# GitHub Actions integration ID (well-known constant). Pinning this means
# the required check must come from Actions specifically and not some
# other CI app that happens to report the same context name.
GH_ACTIONS_INTEGRATION_ID=15368

# Repository role IDs:
#   1 = Read   2 = Triage   3 = Write   4 = Maintain   5 = Admin
ADMIN_ROLE_ID=5

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: 'gh' is not installed." >&2
    exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: 'jq' is required for ruleset payload assembly." >&2
    exit 1
fi

PAYLOAD=$(jq -n \
    --arg name "$RULESET_NAME" \
    --argjson admin_role $ADMIN_ROLE_ID \
    --argjson actions_id $GH_ACTIONS_INTEGRATION_ID \
    '{
        name: $name,
        target: "branch",
        enforcement: "active",
        bypass_actors: [
            {
                actor_id: $admin_role,
                actor_type: "RepositoryRole",
                bypass_mode: "always"
            }
        ],
        conditions: {
            ref_name: {
                include: ["~DEFAULT_BRANCH"],
                exclude: []
            }
        },
        rules: [
            { type: "deletion" },
            { type: "non_fast_forward" },
            {
                type: "pull_request",
                parameters: {
                    required_approving_review_count: 0,
                    dismiss_stale_reviews_on_push: false,
                    require_code_owner_review: false,
                    require_last_push_approval: false,
                    required_review_thread_resolution: false,
                    allowed_merge_methods: ["merge", "squash", "rebase"]
                }
            },
            {
                type: "required_status_checks",
                parameters: {
                    strict_required_status_checks_policy: true,
                    required_status_checks: [
                        {
                            context: "PSP build (pspdev toolchain)",
                            integration_id: $actions_id
                        }
                    ]
                }
            }
        ]
    }')

EXISTING_ID=$(
    gh api "/repos/$REPO/rulesets" \
        --jq ".[] | select(.name==\"$RULESET_NAME\") | .id" \
        2>/dev/null || true
)

if [ -n "$EXISTING_ID" ]; then
    echo "==> Updating ruleset \"$RULESET_NAME\" (id=$EXISTING_ID) on $REPO"
    printf '%s' "$PAYLOAD" | gh api \
        --method PUT \
        --header "Accept: application/vnd.github+json" \
        --input - \
        "/repos/$REPO/rulesets/$EXISTING_ID" \
        > /dev/null
else
    echo "==> Creating ruleset \"$RULESET_NAME\" on $REPO"
    printf '%s' "$PAYLOAD" | gh api \
        --method POST \
        --header "Accept: application/vnd.github+json" \
        --input - \
        "/repos/$REPO/rulesets" \
        > /dev/null
fi

echo
echo "==> Active rulesets on $REPO:"
gh api "/repos/$REPO/rulesets" --jq '.[] | "  [\(.id)] \(.name)  (enforcement=\(.enforcement))"'
