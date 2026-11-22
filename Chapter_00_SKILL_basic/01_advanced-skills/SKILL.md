---
name: advance-testplan-creator
description: Turn a JIRA ticket into a review-ready test plan. Use when a tester or QA lead says "write a test plan for JIRA-1234", "plan testing for this story", "what should we test here", or pastes an acceptance-criteria / user-story ticket. Fetches the ticket, analyzes it for gaps and ambiguities, fills the standard test-plan template, and stops for human review before anything is treated as final.
license: MIT
metadata:
  author: Prramod Dutta from TheTestingAcademy
  stlc-phase: Test Planning
  version: 1.0.0
  tag : [test-plan]
---

# Test Plan Generator

You produce a ** test plan a human still has to approve** - never a "done" artifact. 

## core principle
your job is analysis + drafting +surfacing what is missing, not silent completion.

## When to use
- A JIRA key or story text is provided and someone wants testing planned.
- Someone asks "what are the risks / edge cases/ gaps in this ticket".
- If somebody says "create a test plan for this Jira ticket"
- somebody says "test plan for this ticket"
- test plan for this"

### workflow (follow in order)

###1. Fetch the ticket
- If a JIRA key is given (e.g . 'SCRUM-5') fetch it, run 'scripts/fetch_jira.sh '(needs 'JIRA_BASE_URL', 'JIRA_EMAIL', 'JIRA_TOKEN' in .env). If neither wokrs, ask the user to paste the ticket body - **do not invent ticket content.**
- Capture: summary, description, acceptance criteria, components, linked issues, attachments, and the fix version/sprint.

### 2. Analyze the ticket for acceptance criteria

Run the ticket through 'references/requirement-checklist.md'. for every item, mark
✅ present/⚠️ ambiguous/ missing explicitly list:
- Missing or vague acceptance criteria
- Undefined edge cases, error states, empty/limit/boundary conditions
- Unstated non-functional needs (perf, security, a11y, i18n, permission/roles)
- Missing test data, environment, or dependencies
- Ambiguous wording that two engineers could ready two ways



### 3. Find the missing pieces and gaps

I f you found some gaps Output this as a **"Gaps and Questions for the author"** section. This is the most valuable part - a testers leverage is asking the question before the bug ships.

### 4. draft the test plan

Fill 'references/test-plan-template.md' completely. Drive test scenarios from the acceptance criteria and the gaps you found. Cover positive, negative , boundry and cross-role/permission paths. Tage each scenario P0/P1/P2 by risk and also use the 'misc/mycompanydetails.md' as reference

### 5. stop for human review (mandatory)
End with a **Human Review Gate**:
- Summarize what you assumed and what you could not confirm.
- List open questions from step 2 that block sign-off.
- Ask the tester to confirm/edit before the plan is considered approved.
- Do **not** proceed to write test cases or automation until a human approves.

## output shape
```
## Test Plan - <JIRA_KEY>: <title>
1. scope and objectives
2. Gaps and questions for the author <-- surface missing pieces here
3. Test scenarios (P0/P1/P2)
4. Test data and environment
5. Risks and assumptions
6. Entry and exit criteria
--- Human review gate ---
Assumptions made / open questions / "approve or edit before I continue"
```

## Guardrails and security

- Never mark the plan "final" - a human owns sign off
- Never fabricate acceptance criteria: a missing AC is a finding not a blank to fill.
- Keep scnearios traceable: each maps to an AC or a gap.


## references
- 'references/requirement-checklist.md' - the gap analysis checklist
- 'references/test-plan-template.md' - the test plan template to fill
- 'scripts/fetch_jira.sh' - pull a ticket over the JIRA REST API
- 'copilot/test-plan-copilot.md' - the same skill as a GitHub Copilot prompt file

## Anti hallucination rule

- Never assume anything. if you have any doubt or anything you ask a user
- Always create a test plan from the ticket which is given and ask for any clarification
- Do not invent anything

## when not to use 
Do not use it whenever no proper JIRA ticket has been given or somebody has not even a mentioned a test plan or something.