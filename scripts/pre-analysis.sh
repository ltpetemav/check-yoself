#!/usr/bin/env bash
# pre-analysis.sh — Gather source data for check-yoself review
# Usage: pre-analysis.sh <github-url>
# Outputs: JSON with README excerpt, license, deps, tree, stars, age, issues, maintainer

set -euo pipefail

URL="${1:-}"
if [[ -z "$URL" ]]; then
  echo '{"error":"Usage: pre-analysis.sh <github-url>"}' >&2
  exit 1
fi

# Extract owner/repo from GitHub URL
REPO=$(echo "$URL" | sed -E 's|https?://github\.com/||; s|\.git$||; s|/$||')
if [[ ! "$REPO" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]]; then
  echo "{\"error\":\"Cannot parse owner/repo from URL: $URL\"}" >&2
  exit 1
fi

OWNER=$(echo "$REPO" | cut -d'/' -f1)
REPO_NAME=$(echo "$REPO" | cut -d'/' -f2)

echo "Gathering data for $OWNER/$REPO_NAME..." >&2

# Repo metadata
REPO_JSON=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO_NAME" 2>/dev/null || echo '{}')
STARS=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stargazers_count','?'))" 2>/dev/null || echo "?")
FORKS=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('forks_count','?'))" 2>/dev/null || echo "?")
CREATED=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('created_at','?'))" 2>/dev/null || echo "?")
PUSHED=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('pushed_at','?'))" 2>/dev/null || echo "?")
LICENSE=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('license',{}).get('spdx_id','Unknown'))" 2>/dev/null || echo "Unknown")
SIZE_KB=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('size','?'))" 2>/dev/null || echo "?")
ISSUES=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('open_issues_count','?'))" 2>/dev/null || echo "?")
DESCRIPTION=$(echo "$REPO_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('description',''))" 2>/dev/null || echo "")

# README (first 3000 chars)
README=$(curl -sL "https://raw.githubusercontent.com/$OWNER/$REPO_NAME/main/README.md" 2>/dev/null | head -c 3000 || echo "Not found")

# File tree
TREE=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO_NAME/git/trees/main?recursive=1" 2>/dev/null | \
  python3 -c "
import sys, json
d = json.load(sys.stdin)
for f in d.get('tree', [])[:80]:
    print(f'{f[\"type\"]:4s} {f.get(\"size\",\"-\"):>6} {f[\"path\"]}')
" 2>/dev/null || echo "Could not fetch tree")

# Dependency files (check common patterns)
DEPS=""
for dep_file in package.json pyproject.toml Cargo.toml requirements.txt go.mod; do
  dep_content=$(curl -sL "https://raw.githubusercontent.com/$OWNER/$REPO_NAME/main/$dep_file" 2>/dev/null)
  if [[ -n "$dep_content" && "$dep_content" != "404"* ]]; then
    DEPS="$DEPS\n--- $dep_file ---\n$(echo "$dep_content" | head -60)"
  fi
done

# Output structured report
cat << JSONEOF
{
  "repo": "$OWNER/$REPO_NAME",
  "description": $(python3 -c "import json; print(json.dumps('$DESCRIPTION'))" 2>/dev/null || echo "\"\""),
  "stars": "$STARS",
  "forks": "$FORKS",
  "created": "$CREATED",
  "last_push": "$PUSHED",
  "license": "$LICENSE",
  "size_kb": "$SIZE_KB",
  "open_issues": "$ISSUES",
  "tree_preview": "see stderr",
  "deps_found": "see stderr"
}
JSONEOF

# Detailed output to stderr (for context injection)
echo "" >&2
echo "=== REPO METADATA ===" >&2
echo "Stars: $STARS | Forks: $FORKS | Issues: $ISSUES | Size: ${SIZE_KB}KB" >&2
echo "Created: $CREATED | Last push: $PUSHED | License: $LICENSE" >&2
echo "" >&2
echo "=== README (first 3000 chars) ===" >&2
echo "$README" >&2
echo "" >&2
echo "=== FILE TREE ===" >&2
echo "$TREE" >&2
echo "" >&2
echo "=== DEPENDENCIES ===" >&2
echo -e "$DEPS" >&2
