# Worked Example: OpenViking Analysis

**Tool:** OpenViking — ByteDance's open-source "Context Database for AI Agents"
**Source:** https://github.com/volcengine/OpenViking
**Trigger:** Viral tweet from @teksedge claiming it "changes everything" for AI memory systems

## Phase 0 — Pre-Analysis

Gathered: README, Apache 2.0 license, Python+Go+Rust+C++ stack, 30+ Python deps including hard `volcengine` SDK dependency, FastAPI server on :1933, AGFS (Go FUSE binary), pybind11 C++ extensions.

Repo: 2 months old, v0.x, trending on GitHub.

## Phase 1 — 5 Reviewers (Condensed Findings)

**🔒 Security:** volcengine SDK (ByteDance cloud) is a HARD dependency even for non-Volcengine users. Server has zero authentication. AGFS needs kernel-level FUSE access. **Rating: ⚠️ CAUTION**

**🏗️ Architect:** 6-category memory taxonomy is genuinely good design (Profile, Preferences, Entities, Events, Cases, Patterns). L0/L1/L2 tiered loading is smart. But our markdown files already ARE a filesystem — the "filesystem paradigm" is marketing for what we already do differently. **Verdict: BORROW-IDEAS**

**😈 Devil's Advocate:** "Your system has shipped real products. OpenViking has shipped a README." Adopting would add Python server + Go binary + C++ compilation to a Node.js stack. Complexity cost is massive for marginal retrieval improvement on a ~50 file corpus. **Verdict: SKIP the tool, BORROW the ideas**

**⚡ Performance & Cost:** Adds $2-5/mo in embedding + VLM costs. Token savings from tiered loading on our workload: ~$0.06/mo. Net: cost increase. The "91% savings" assumes scale we don't have. **Verdict: NET COST INCREASE**

**🔧 Integration:** Python server requires HTTP bridging from Node.js. FUSE doesn't work on macOS without kernel extensions. Minimum viable integration is still a second server process + second language runtime. **Verdict: HIGH FRICTION**

### Synthesis

**Consensus:** All 5 — don't install the code. The ideas are portable.
**Key Dissent:** Architect valued the structured taxonomy more than Devil's Advocate (who called it "renaming what we already do").
**Verdict: BORROW-IDEAS**

## Phase 2 — Implementation Plan (Borrowing Ideas)

1. Restructure MEMORY.md into 6 categories (1h, Medium risk)
2. Add TL;DR summaries to daily files (30min, Low risk)
3. Category-aware memory extraction in nightly-synthesis (2h, Medium risk)
4. Tiered context loading for crons (2h, High risk — silent degradation)
5. Memory deduplication (2h, High risk — irreversible)
6. Validate and measure (1h, None)

## Phase 3 — Blast Radius (Condensed)

| Step | Blast Radius | Worst Case | Reversible? |
|------|-------------|------------|-------------|
| 1. Restructure MEMORY.md | 🔴 Wide | Pruning rules break silently | Yes (git revert) |
| 2. TL;DR in daily files | 🟢 Narrow | Slightly larger files | Yes |
| 3. Category extraction | 🟡 Medium | Wrong categorization loses context | Yes |
| 4. Tiered loading | 🔴 Wide | Crons make worse decisions for weeks | Yes but damage accumulates |
| 5. Memory dedup | 🔴 Wide | Permanent data loss from false matches | **NO** |
| 6. Validate | 🟢 Narrow | None | N/A |

**Risk-adjusted reorder:** 6→2→1→3→4→5 (baseline first, irreversible last)
**Phased rollout:** 4 weeks, one step per week, measurement after each.

## Final Verdict

**BORROW-THE-GOOD-PARTS** — Take the GPS, leave the rocket fuel.
