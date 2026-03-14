#!/bin/bash
# Morning email triage — runs via launchd at 8:30 on weekdays
# Runs Claude Code autonomously, then opens a terminal for optional follow-up

# === CONFIGURE THESE ===
WORKDIR="$HOME/projects/claude-email-assistant"  # Path to this project
CALENDAR_ID="your_calendar_id@group.calendar.google.com"  # Your ops calendar
RECURRING_EVENT_ID="your_recurring_event_id"  # Recurring "Email Replies" event (optional)
TIMEZONE="Europe/Prague"  # Your timezone
# === END CONFIG ===

LOG_DIR="$HOME/Library/Logs/claude-morning-triage"
mkdir -p "$LOG_DIR"

PROMPT="Run the morning email triage AUTONOMOUSLY — do NOT wait for my input at any step. Draft everything, label everything, save everything. I will review in Gmail later.

1. Set gws env vars and run gws gmail +triage to get inbox summary.

2. Run the draft-vs-sent learning loop:
   - Fetch messages sent in last 24h
   - Cross-reference with .claude/skills/reply-email/drafts-log.md
   - If we find drafts that were sent with edits, log the learnings to learned-replies.md

3. For ALL emails that need a reply (Unread + Important + no action labels):
   - Classify each email (info / reply / ops) per the /reply-email skill rules
   - Label info and ops emails immediately
   - Draft replies for all reply-needed emails WITHOUT asking for confirmation
   - Save each as a Gmail Draft and label with AI ready
   - Log each draft in drafts-log.md

4. Write a summary to scripts/morning-triage-latest.md AND show it in the terminal:
   - Date and time
   - Number of unread emails processed
   - Number of drafts created. For each draft show: sender, subject, and estimated time to review+send (e.g. '30s send as-is', '2min needs review', '5min needs rewrite')
   - Total estimated time to clear all drafts (sum of individual estimates)
   - Number of emails labeled info / ops. For ops emails, estimate time needed (e.g. '5min download invoice', '15min review contract')
   - Total estimated time for all ops tasks
   - Any learnings from draft-vs-sent comparison
   - Emails flagged as high priority

5. Create a calendar event in the ops calendar (ID: $CALENDAR_ID):
   - Title: 'Email Replies'
   - Start: today at 08:45 ($TIMEZONE)
   - Duration: minimum 15 minutes, BUT expand if estimated total time (drafts + ops) exceeds 15 min. Round up to nearest 5 min.
   - Description: paste the full summary from step 4
   - Transparency: opaque (shows as Busy)

Do NOT ask me anything. Just do it all and show the summary at the end."

# Open iTerm2 with a distinct dark-blue background and custom tab title
osascript -e "
tell application \"iTerm\"
    activate
    set newWindow to (create window with default profile)
    tell current session of newWindow
        -- Dark navy background to distinguish from regular terminals
        set background color to {6682, 8738, 16384}
        -- Set tab/window title
        write text \"printf '\\\\e]1;Email Triage\\\\a' && printf '\\\\e]2;Email Triage\\\\a' && cd '$WORKDIR' && claude --dangerously-skip-permissions --model sonnet --max-budget-usd 2.00 '$PROMPT'\"
    end tell
end tell
"
