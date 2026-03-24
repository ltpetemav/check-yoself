---
name: check-yoself
description: |
  Deep analysis and blast radius assessment for evaluating new tools, skills,
  libraries, frameworks, or infrastructure before adoption. Combines multi-perspective
  adversarial review (PRISM-style) with blast radius mapping to prevent hype-driven
  decisions from breaking working systems. Use when: (1) evaluating a new open-source
  tool or framework, (2) considering adding a skill or integration to OpenClaw,
  (3) reviewing any technology that looks "game-changing" on Twitter/HN/Reddit,
  (4) assessing whether to adopt, borrow ideas from, or skip a technology,
  (5) someone says "we should use X" and you need structured analysis before deciding.
  Triggers: "vet this", "should we adopt", "analyze this tool", "is this safe to use",
  "blast radius", "deep analysis on", "evaluate for adoption", "check yoself".
license: MIT
metadata:
  author: quirkyquirk
  version: "1.0.0"
---

# Check Yoself Before You Wreck Yoself

Structured analysis protocol for evaluating new technologies before they touch your system.

**Core principle:** Hype moves fast. Blast radius analysis moves carefully. Always run both.

## Dependencies

- `sessions_spawn` — parallel sub-agent dispatch (OpenClaw built-in)
- `web_fetch` — gather README, source files, dependency lists
- `web_search` — find additional context, tweets, articles, discussions
- Model: sonnet (default), haiku (quick checks), opus (critical infra decisions)

## When to Use

- A viral tweet/post makes a tool look revolutionary
- Someone recommends a new dependency, framework, or integration
- You're tempted to `pip install` or `npm install` something that replaces working infrastructure
- A new OpenClaw skill or plugin is being considered
- Any decision where "this changes everything" is the initial reaction

## The Protocol (3 Phases)

### Phase 0 — Pre-Analysis (Automated)

Run the pre-analysis script to gather source data:

```bash
bash ~/.openclaw/skills/check-yoself/scripts/pre-analysis.sh <github-url>
```

Outputs structured JSON with: README, license, deps, tree, stars, age, issues, maintainer. If no GitHub URL, gather manually per the checklist below.

**Manual fallback checklist:**
- [ ] README / main docs
- [ ] License
- [ ] Dependency list (package.json, pyproject.toml, etc.)
- [ ] Source tree structure
- [ ] Telemetry/analytics code
- [ ] GitHub stars, age, last commit, open issues
- [ ] Maintainer (individual, company, community)

Include gathered data in every reviewer's prompt as shared context.

### Phase 1 — Multi-Perspective Analysis

Deploy 5 specialist reviewers as sub-agents in parallel. Each gets the same source material but analyzes from a different angle.

**The 5 Perspectives:**

| # | Reviewer | Core Question | Focus Areas |
|---|----------|---------------|-------------|
| 1 | 🔒 **Security Auditor** | "How could this hurt us?" | Dependencies, telemetry, auth, supply chain, data exfiltration, license |
| 2 | 🏗️ **Systems Architect** | "What does this give us vs. what we have?" | Capabilities gap, what's better/worse, migration path |
| 3 | 😈 **Devil's Advocate** | "Real problem or interesting distraction?" | Shiny object risk, complexity cost, failure scenarios, 80/20 alternative |
| 4 | ⚡ **Performance & Cost** | "Show me the numbers." | Runtime cost, infra cost, latency, resource overhead |
| 5 | 🔧 **Integration Engineer** | "How would this actually work?" | Compatibility, minimum viable integration, friction points |

See `references/reviewer-prompts.md` for full prompt templates.

**Spawn config:** model=sonnet, timeout=180s, mode=run. If agents time out, synthesize yourself from gathered source data.

### Phase 2 — Implementation Plan

Only if Phase 1 verdict is **ADOPT** or **BORROW-IDEAS**. Skip if **SKIP** or **WATCH**.

Each step needs: number, description, time estimate, risk rating (None/Low/Medium/High), dependencies, rollback plan.

### Phase 3 — Blast Radius Analysis

Run on EVERY step from Phase 2. For each step ask:

1. **What touches this?** — Every file, cron, agent, service, workflow affected.
2. **What breaks?** — Concrete failure modes, not vague concerns.
3. **What degrades silently?** — Won't error but produces worse results. Most dangerous.
4. **Is this reversible?** — Can you git revert? If not, what safeguards?
5. **Blast radius?** — 🟢 Narrow (one component) / 🟡 Medium (multiple) / 🔴 Wide (everything)

**After analysis:** Reorder by risk (lowest first, irreversible last). Add safeguards for 🔴 steps. Add baseline measurement as Step 0. Convert to phased weekly rollout.

### Verification Step

After completing all 3 phases, verify:
- [ ] All 5 reviewers returned findings (or timeout was handled)
- [ ] Synthesis includes a "Key Dissent" section (disagreements > consensus)
- [ ] Verdict is one of: ADOPT / BORROW-IDEAS / WATCH / SKIP
- [ ] Blast radius covers every implementation step (count must match)
- [ ] Every irreversible step has explicit safeguards documented
- [ ] Risk-adjusted order differs from original order (if it doesn't, blast radius didn't change anything — suspicious)

## Output Format

### Synthesis Report

```markdown
## 🔱 Vet Report: [Tool Name]

### Consensus
[What all/most reviewers agreed on]

### Key Dissent
[Where reviewers disagreed — most valuable part]

### Verdict: [ADOPT / BORROW-IDEAS / WATCH / SKIP]

### What to Actually Do
[Concrete next steps]

### What NOT to Do
[Explicit things to avoid]

### When to Revisit
[Conditions that would change the verdict]
```

### Blast Radius Table

```markdown
| Step | Blast Radius | Worst Case | Reversible? |
|------|-------------|------------|-------------|
| 1. X | 🟢 Narrow | ... | Yes |
| 2. Y | 🔴 Wide | ... | NO |
```

### Risk-Adjusted Execution Order

Present reordered plan with phase/week assignments, safeguards, and validation checkpoints.

See `references/scorecard.md` for the output quality checklist.

## Verdict Scale

| Verdict | Meaning | Action |
|---------|---------|--------|
| **ADOPT** | Worth the complexity. Real gap. Safe enough. | Full plan + blast radius |
| **BORROW-IDEAS** | Ideas good, code/infra not right for us. | Implement concepts in existing stack |
| **WATCH** | Promising but too early or wrong scale. | Revisit in N months. |
| **SKIP** | Not worth it. Wrong problem or unjustified complexity. | Move on. |

## Cost Control

- sonnet default (~$0.50-1.00 for all 5 reviewers)
- `--haiku` for quick checks (~$0.15-0.30)
- `--opus` for critical infra decisions only (~$2.00-3.00)
- If 3+ agents time out: synthesize yourself, don't re-run

## Gotchas & Known Limitations

- **Sub-agent timeout (180s) may not be enough** for tools with large codebases or when web research is needed. The OpenViking analysis had all 5 agents time out at 120s. Increase to 300s for complex tools, or synthesize yourself from gathered data.
- **GitHub rate limiting** — `pre-analysis.sh` uses unauthenticated API calls (60/hr limit). If rate-limited, the script returns partial data. Gather remaining info manually.
- **Haiku model misses nuanced security issues** — always use sonnet minimum for the Security Auditor reviewer, even in quick-check mode.
- **Blast radius quality depends on system knowledge** — reviewers analyzing a tool they've never seen produce generic blast radius. The human running this needs to know their own system well enough to validate.
- **"BORROW-IDEAS" is the hardest verdict to execute** — it requires writing an implementation plan for concepts without reference code. Budget extra time for this verdict.
- **New/trending repos have inflated signal** — high star velocity doesn't mean production-ready. Weight last-commit age and issue-response-time over star count.

See `references/example-openviking.md` for a real worked example showing the full protocol.
