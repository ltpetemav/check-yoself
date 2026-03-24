# Check Yoself Output Scorecard

Run this checklist after completing a vet report to verify quality.

## Phase 1 — Multi-Perspective Analysis

| # | Check | Pass? |
|---|-------|-------|
| 1 | All 5 reviewer perspectives are represented in the synthesis | Y/N |
| 2 | Each reviewer gave a concrete verdict (not just "it depends") | Y/N |
| 3 | Security Auditor checked: dependencies, telemetry, auth, license | Y/N |
| 4 | Devil's Advocate challenged the premise, not just the implementation | Y/N |
| 5 | Performance & Cost gave actual numbers, not vibes | Y/N |
| 6 | Synthesis includes a "Key Dissent" section | Y/N |
| 7 | Final verdict is exactly one of: ADOPT / BORROW-IDEAS / WATCH / SKIP | Y/N |

## Phase 2 — Implementation Plan (if applicable)

| # | Check | Pass? |
|---|-------|-------|
| 8 | Every step has a time estimate | Y/N |
| 9 | Every step has a risk rating (None/Low/Medium/High) | Y/N |
| 10 | Every step has a rollback plan | Y/N |
| 11 | Dependencies between steps are documented | Y/N |

## Phase 3 — Blast Radius Analysis (if applicable)

| # | Check | Pass? |
|---|-------|-------|
| 12 | Blast radius table covers every implementation step (count matches) | Y/N |
| 13 | At least one step checks for silent degradation (not just hard failures) | Y/N |
| 14 | Irreversible steps are explicitly flagged with safeguards | Y/N |
| 15 | Risk-adjusted order differs from original order (if identical, analysis didn't find anything — suspicious) | Y/N |
| 16 | Phased rollout has validation checkpoints between phases | Y/N |

## Scoring

- **13-16/16:** Thorough analysis. Ship it.
- **10-12/16:** Adequate. Gaps are cosmetic.
- **<10/16:** Re-run the weak phase before acting on the verdict.

**Note:** Phases 2-3 are N/A when verdict is WATCH or SKIP. Score only Phase 1 (7 checks) in that case.
