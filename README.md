# Check Yoself Before You Wreck Yoself 🔱

Structured analysis protocol for evaluating new technologies before they touch your system. Combines multi-perspective adversarial review with blast radius mapping.

## What It Does

- **5 specialist reviewers** analyze the tool from different angles (Security, Architecture, Devil's Advocate, Performance, Integration)
- **Blast radius analysis** maps what breaks, what degrades silently, and what's irreversible
- **Risk-adjusted implementation plan** reorders steps by risk and adds safeguards
- **Pre-analysis script** gathers GitHub metadata, README, deps, and file tree automatically
- **Verdict framework** — ADOPT / BORROW-IDEAS / WATCH / SKIP

## Install

### Claude Code / OpenClaw

```bash
# Clone into your skills directory
git clone https://github.com/ltpetemav/check-yoself.git ~/.openclaw/skills/check-yoself
```

### Cursor / Windsurf

Copy the `check-yoself/` directory into your project's `.cursor/skills/` or equivalent.

## Setup

1. Clone the repo (see Install above)
2. Verify the pre-analysis script is executable:
   ```bash
   chmod +x ~/.openclaw/skills/check-yoself/scripts/pre-analysis.sh
   ```
3. Requires: `curl`, `python3`, `bash` (macOS/Linux built-in)
4. No API keys or external services needed

## Usage: Natural Language

Just talk to your agent:

- *"Vet this: https://github.com/example/cool-tool"*
- *"Should we adopt this framework?"*
- *"Check yoself on this dependency before we add it"*
- *"Run a blast radius analysis on switching to X"*
- *"Is this safe to use? https://github.com/..."*

## Usage: Explicit Steps

```bash
# Phase 0 — Gather data
bash ~/.openclaw/skills/check-yoself/scripts/pre-analysis.sh https://github.com/owner/repo

# Phase 1 — 5 reviewers analyze in parallel (agent handles this)
# Phase 2 — Implementation plan (if verdict is ADOPT or BORROW-IDEAS)
# Phase 3 — Blast radius on every implementation step
```

## The 3 Phases

| Phase | What Happens | Output |
|-------|-------------|--------|
| **0 — Pre-Analysis** | Gather source data (README, deps, tree, stars) | Structured JSON |
| **1 — Multi-Perspective Review** | 5 specialist sub-agents analyze the tool | Synthesis report with verdict |
| **2 — Implementation Plan** | Numbered steps with time/risk/rollback | Phased plan |
| **3 — Blast Radius** | Per-step analysis of what breaks | Risk-adjusted execution order |

## The 5 Reviewers

| Reviewer | Core Question |
|----------|---------------|
| 🔒 **Security Auditor** | "How could this hurt us?" |
| 🏗️ **Systems Architect** | "What does this give us vs. what we have?" |
| 😈 **Devil's Advocate** | "Real problem or interesting distraction?" |
| ⚡ **Performance & Cost** | "Show me the numbers." |
| 🔧 **Integration Engineer** | "How would this actually work?" |

## Verdict Scale

| Verdict | Meaning | Next Step |
|---------|---------|-----------|
| **ADOPT** | Worth it. Real gap. Safe. | Full plan + blast radius |
| **BORROW-IDEAS** | Ideas good, code not right for us | Implement concepts in existing stack |
| **WATCH** | Promising but too early | Revisit in N months |
| **SKIP** | Not worth it | Move on |

## Configuration

| Setting | Default | Notes |
|---------|---------|-------|
| Model | sonnet | Use haiku for quick checks, opus for critical infra |
| Sub-agent timeout | 180s | Increase to 300s for large repos |
| Reviewers | 5 | All 5 always run (no partial mode) |

## Security

- Pre-analysis script makes **unauthenticated** GitHub API calls (60/hr rate limit)
- No credentials stored or transmitted
- No telemetry or analytics
- Sub-agents run in isolated sessions — no cross-agent data leakage
- Script validates GitHub URL format before making API calls

## Limitations

- GitHub API rate limit (60 unauthenticated calls/hr) may limit rapid successive analyses
- Sub-agents may time out on very large repos (>50K lines) — synthesize manually if needed
- Blast radius quality depends on how well you know your own system
- "BORROW-IDEAS" verdict is hardest to execute (no reference implementation to copy)
- Trending repos have inflated signals — weight age and issue-response-time over star count

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `pre-analysis.sh` returns partial data | GitHub rate limit | Wait 1hr or authenticate with `GITHUB_TOKEN` |
| Sub-agents all time out | Repo too large or model too slow | Increase timeout to 300s or synthesize manually |
| Blast radius seems generic | Reviewers lack system context | Add more detail to "[OUR SYSTEM]" in prompts |
| Script fails on non-GitHub URL | Only GitHub URLs supported | Gather data manually for other sources |

## File Structure

```
check-yoself/
├── SKILL.md              # Skill instructions + protocol definition
├── LICENSE.txt            # MIT License
├── README.md              # This file
├── .gitignore             # Standard ignores
├── scripts/
│   └── pre-analysis.sh   # GitHub repo data gatherer
└── references/
    ├── reviewer-prompts.md     # Full prompt templates for all 5 reviewers
    ├── scorecard.md            # Output quality checklist (16-point)
    └── example-openviking.md   # Worked example showing the full protocol
```

## Credits

Built by [ltpetemav](https://github.com/ltpetemav) for the [OpenClaw](https://openclaw.ai) ecosystem.

Inspired by the [PRISM](https://github.com/jeremyknows/PRISM) multi-agent review protocol by [@jeremyknows](https://github.com/jeremyknows).

## License

MIT — see [LICENSE.txt](LICENSE.txt)
