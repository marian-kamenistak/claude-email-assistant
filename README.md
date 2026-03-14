# Claude Code Email Assistant

An autonomous email triage and reply system built with [Claude Code](https://claude.ai/claude-code) and Google Workspace CLI (`gws`).


Every workday at 8:30, Claude Code reads your inbox, drafts replies in your voice, saves them as Gmail drafts, and blocks time in your calendar. You wake up, open Gmail, review the drafts, and hit Send.

The system learns from every edit you make. If you change a draft before sending, next morning it compares what it wrote vs what you actually sent — and adjusts.

## How it works

```
8:30  launchd triggers Claude Code
        │
        ▼
┌─────────────────┐
│ 1. Triage inbox │  Classify emails: reply / info / ops
│ 2. Learn        │  Compare yesterday's drafts vs what was sent
│ 3. Draft        │  Write replies in your voice, save as Gmail Drafts
│ 4. Label        │  Tag emails: AI ready / info / ops / high / $
│ 5. Summarize    │  Estimate time per email
│ 6. Calendar     │  Block time based on actual workload
└─────────────────┘
        │
        ▼
┌─────────────────┐
│ You open Gmail   │  Drafts are there, in the right threads
│ ✓ Send as-is    │  Most drafts just need one click
│ ✎ Edit + Send   │  Fix anything directly in Gmail
│ ✗ Delete        │  Skip what doesn't need a reply
└─────────────────┘
        │
        ▼
┌─────────────────┐
│ Next morning     │  System diffs drafts vs sent messages
│ Learns from edits│  Every correction improves future drafts
└─────────────────┘
```

## What you get

- **Gmail Drafts** — replies appear in the right threads, ready to send
- **Gmail Labels** — emails auto-categorized: `AI ready`, `info`, `ops`, `high`, `$`
- **Calendar block** — dynamic time block based on actual email volume
- **Self-improving** — learns your voice from corrections, not just from examples
- **Time estimates** — know exactly how long your email block will take

## Prerequisites

- macOS (uses `launchd` for scheduling)
- [Claude Code CLI](https://claude.ai/claude-code) installed (`/usr/local/bin/claude`)
- [gws CLI](https://github.com/nicholasgasior/gws) — Google Workspace CLI with Gmail and Calendar access
- iTerm2 (optional, for the interactive terminal with distinct styling)
- A Google Workspace account with Gmail API and Calendar API enabled

## Installation

See [INSTALL.md](INSTALL.md) for the full setup guide.

## Quick start

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/claude-email-assistant.git
cd claude-email-assistant

# 2. Run the setup script
./setup.sh

# 3. Test it
./scripts/morning-triage.sh
```

## Project structure

```
claude-email-assistant/
├── CLAUDE.md                          # Claude Code project instructions
├── INSTALL.md                         # Full installation guide
├── setup.sh                           # Interactive setup script
├── scripts/
│   └── morning-triage.sh             # The scheduler script (launched by launchd)
├── launchd/
│   └── com.claude.morning-triage.plist  # macOS scheduler config
├── skills/
│   └── reply-email/
│       ├── SKILL.md                   # Reply drafting skill definition
│       ├── email-voice-guide.md       # Your email voice examples (you fill this in)
│       ├── learned-replies.md         # Auto-populated from corrections
│       └── drafts-log.md             # Draft tracking for the learning loop
└── shared/
    └── communication-style.md         # Your writing style rules
```

## The learning loop

This is the key differentiator. Most AI email tools are fire-and-forget. This one learns.

1. **Morning**: Claude drafts replies based on your voice guide + past corrections
2. **You**: Review in Gmail. Send as-is, edit and send, or delete
3. **Next morning**: Claude compares what it drafted vs what you actually sent
4. **Result**: Every word you change, every sentence you shorten, every draft you delete teaches it something

After ~30 corrections, the drafts start sounding like you actually wrote them.

## Gmail labels

The system uses labels to track email state:

| Label | Meaning |
|-------|---------|
| `AI ready` | Draft created, waiting for you to review and send |
| `info` | No reply needed (newsletters, notifications, FYIs) |
| `ops` | Needs operational work (download invoice, sign doc, update system) |
| `high` | Urgent / time-sensitive |
| `$` | Invoice or billing context |

## Calendar integration

Each morning, the system creates a calendar event with:
- **Dynamic duration**: minimum 15 min, expands based on actual email volume
- **Summary in description**: full breakdown of what needs attention
- **Time estimates**: per-email estimates so you know exactly what you're walking into

## Customization

### Your voice
Edit `skills/reply-email/email-voice-guide.md` with 10-20 real emails you've sent. The more examples, the better the voice match. Include:
- Quick confirmations (1-liners)
- Scheduling emails (dates + calendar link)
- Client replies (proposals, follow-ups)
- Casual emails (networking, community)

### Your style rules
Edit `shared/communication-style.md` with your writing rules:
- Words you never use
- How you sign off
- Your tone by context (casual vs professional)
- Anti-patterns to avoid

### Schedule
Edit the launchd plist to change when the triage runs. Default is weekdays at 8:30.

## Limitations

- macOS only (launchd). Linux users can adapt to cron/systemd.
- Requires `gws` CLI with Google Workspace API access.
- The learning loop needs ~1 week of corrections to start producing good drafts.
- Claude Code CLI subscription required.
- Calendar integration requires a Google Calendar you own (not just read access).

## License

MIT
