---
name: engineer-epic-health-update
description: "Helps a Privacy & AI Gov engineer write this week's Health and Health Update for every PRIV epic they own. Gathers evidence from #privacy-team-standups, the AI Gov project channels, child ticket activity and linked GitHub PRs, checks each epic has a due date, rates Health from the due date and progress, drafts a short prose update, and writes both fields to Jira. Use this whenever someone asks to do their health updates, update their epics, fill in Health / Health Update, prep for the Friday roll-up, or responds to the Friday health reminder, even if they don't name the skill."
---

# Engineer epic health update (Privacy & AI Gov)

Every Friday at 4pm UK time, the `feature-health-update` roll-up collects the **Health** and **Health Update** fields on PRIV epics and posts a per-Feature summary. This skill helps the engineer who owns each epic fill those fields in first, from evidence rather than memory.

The person running this is the epic owner. Everything is read and written through their own Jira and Slack connections. If either connector isn't available, say so and ask them to connect it. Carry on with whatever sources are available, but don't write to Jira without the Jira connector.

## Fixed reference values

| Thing | Value |
| --- | --- |
| Jira site | `vanta.atlassian.net`, project `PRIV` |
| Health | `customfield_10096` (select: `On Track`, `At Risk`, `Off Track`) |
| Health Update | `customfield_10095` (small free-text field) |
| Due date | `duedate` |
| GitHub repo | `VantaInc/obsidian` |
| Standups channel | `#privacy-team-standups` |
| Project channels | `#ai-gov-eng-team`, `#proj-epd-ai-gov`, `#proj-epd-ai-guardrails`, `#proj-make-ai-gov-decisions`, `#proj-ai-gov-violation-alerts`, `#proj-ai-governance-documentation` |

Don't touch Health History, Health Snapshot, Health Update Snapshot or Health Last Changed; an automation owns them.

## Step 1: Ask how they want to work

Before gathering anything, ask one question (with tappable options if available):

- **Review each first:** draft every epic, show the drafts, and write only what they approve.
- **Write them all:** draft and write in one go, then show what was written.

Even in "write them all" mode, still stop for anything this skill would otherwise ask about: a missing due date, or a proposed status change out of Backlog.

## Step 2: Find their epics

The owner of an epic is its **assignee**. They update the epic even when its child tickets belong to other people. Use `assignee = currentUser()`.

1. **Active:** `project = PRIV AND issuetype = Epic AND assignee = currentUser() AND statusCategory = "In Progress"`
2. **Closed this week:** `project = PRIV AND issuetype = Epic AND assignee = currentUser() AND statusCategory = Done AND statusCategoryChangedDate >= "<Monday>"`. Confirm the date in UTC (see "The window"). An epic that closed this week still needs a final update.
3. **Backlog with active children:** `project = PRIV AND issuetype = Epic AND assignee = currentUser() AND status = Backlog`. For each, check its children (`parent = <EPIC>`). A child counts as **active** only if it's in the In Progress status category *and* was updated in the last 2 weeks.
   - **Active child:** propose moving the epic to **In Progress** (find the transition with `getTransitionsForJiraIssue`). Ask before transitioning, in either mode, then include the epic.
   - **Child In Progress but untouched for 2+ weeks:** don't propose the transition. Ask instead: "Move the epic to In Progress, or move <CHILD> back to To Do?" Act on the answer.
   - **No children In Progress:** leave the epic alone; it may simply not have started.

If they own no epics in scope, say so and stop.

## The window

Evidence counts from the **later** of:

- Monday 00:00 Europe/London this week, or
- the last change to the epic's Health Update (from the changelog).

That way each update covers what's new since the last one. Jira reports times in US time (e.g. `-0500`) and JQL dates use the user's timezone, so compare in UTC.

## Step 3: Gather evidence per epic

For each epic, collect:

- **The epic itself:** summary, description, status, due date, current Health and Health Update. Use `getJiraIssue` with `expand: changelog`.
- **Child tickets:** `parent = <EPIC>`. For each, note status, assignee, and status changes and comments inside the window. Count children by status category: To Do, In Progress, Done.
- **Standups:** messages in `#privacy-team-standups` inside the window, by the engineer or mentioning the epic key or any child key. Use the Slack search tool with `in:#privacy-team-standups after:<date>`.
- **Project channels:** messages and threads in the project channels above that mention the epic key, a child key, or the epic's clear name. Read the thread when a hit is a reply or has replies.
- **GitHub:** PRs in `VantaInc/obsidian` that mention the epic or a child key in the title or branch, merged or opened inside the window. Use `search_pull_requests`, e.g. `repo:VantaInc/obsidian PRIV-2286`. Note merged vs open and any long-waiting reviews.

Keep each source tied to the epic it came from. Don't let one epic's news leak into another's update.

## Step 4: Due date check

If the epic has **no due date**, hold the Health field: don't rate it or write it. Tell the engineer, and offer to set the date if they give one in chat (`editJiraIssue` with `duedate: "YYYY-MM-DD"`). Once the date is set, rate and continue as normal.

If they don't give a date, you can still write the Health Update text. Warn them that the Friday roll-up treats an epic with no Health as not updated, so they'll be nudged.

## Step 5: Rate Health

Pick one rating from the evidence. Today's date and the due date drive it:

- **Off Track:** the due date has passed and work is still open, or a blocker means it clearly can't land by the due date.
- **At Risk:** any of:
  - due within 2 working days with any child story not Done (Won't Do counts as done);
  - due within 5 working days with a meaningful share of child tickets still To Do (roughly a third or more);
  - an unresolved blocker or dependency in the sources.
- **On Track:** everything else, including epics that closed this week.

Give a one-line reason with each rating, e.g. "Due 27 Nov, 2 of 7 stories still To Do, no blockers". The engineer can override any rating; take their call without arguing. If they choose a rating the evidence doesn't support, mention the mismatch once, then use their choice.

## Step 6: Draft the Health Update

The field is small and shows plain text, so write **prose**: 2–4 short sentences, ideally under about 400 characters. No headings, bullets or markdown. Cover, in this order:

1. What happened this week.
2. What's next.
3. Any blocker, saying who or what it's waiting on.

Leave out a part that has nothing to say rather than writing "none".

Rules:

- Write it fresh each week. Never carry over last week's text; the roll-up treats stale text as no update.
- Use only what the evidence supports. No invented dates, progress or blockers. If evidence is thin, say so to the engineer and ask them for a line rather than padding.
- Write in the team's plain voice: past tense for done, specific nouns ("deny list in the guardrail drawer"), not vague verbs ("worked on improvements").
- For a closed epic, say what shipped. Mention follow-ups only if the evidence names them.

Example (In Progress, At Risk):

> Product signals now flow into guardrail evaluation and unapproved-product violations are raised in staging. Next is the deny list in the guardrail drawer. At risk: the drawer change is waiting on design sign-off from Nic, with the due date 27 Nov.

## Step 7: Show, confirm, write

Show one block per epic:

- Key, title, status, due date.
- Proposed Health, and what it is now, with the reason.
- Proposed Health Update text, and the current text for comparison.
- Key evidence links (standup messages, threads, PRs, tickets), at most about 5.
- Anything needing their input: missing due date, Backlog transition, or thin evidence.

In **review** mode, ask them to approve all, edit some, or skip some. Act only on their answer.

To write, use `editJiraIssue` for each epic: `{"customfield_10096": {"value": "<rating>"}, "customfield_10095": "<text>"}`. Omit `customfield_10096` when the Health is held for a missing due date.

Finish with a short confirmation of each epic written, with its link. Also list anything left undone, e.g. "PRIV-2235: Health held, no due date".
