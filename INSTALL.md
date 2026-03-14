# Installation Guide

## Step 1: Install prerequisites

### Claude Code CLI

```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Verify
claude --version
```

You need an active Claude subscription (Pro or Max).

### gws CLI (Google Workspace)

```bash
# Install gws
# See: https://github.com/nicholasgasior/gws
brew install nicholasgasior/tools/gws
```

### Google Cloud Setup

The `gws` CLI needs Google Cloud credentials with Gmail and Calendar APIs enabled.

```bash
# 1. Create a Google Cloud project (or use existing)
# 2. Enable these APIs:
#    - Gmail API
#    - Google Calendar API

# 3. Create OAuth 2.0 credentials (Desktop application type)
# 4. Download the credentials JSON

# 5. Authenticate
gws auth login
```

### iTerm2 (optional)

The morning triage opens an iTerm2 window with a distinct dark background. If you prefer Terminal.app, edit `scripts/morning-triage.sh` accordingly.

## Step 2: Run setup

```bash
cd claude-email-assistant
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Ask for your working directory path
2. Ask for your Google Calendar ID (for the ops calendar)
3. Ask for your timezone
4. Generate the launchd plist
5. Create Gmail labels
6. Install the launchd agent

### Manual setup (if you prefer)

#### 2a. Configure your details

Edit these files with your information:

**`CLAUDE.md`** — Update:
- Your name and contact info
- Your calendar link
- Your phone number

**`skills/reply-email/email-voice-guide.md`** — Add 10-20 real emails you've sent. This is the most important file — it teaches Claude your voice. Structure:

```markdown
## Your Language (e.g., English, Czech)

### How your emails actually sound

\```
[paste a real email you sent]
\```

\```
[paste another one]
\```

### Patterns
- How you open emails
- How you sign off
- Words you use often
- Words you never use
```

**`shared/communication-style.md`** — Your writing rules:
- Tone (casual, professional, mixed)
- Anti-patterns (words/phrases to never use)
- Sign-off preferences

#### 2b. Create Gmail labels

Create these labels in Gmail (Settings → Labels → Create new label):

| Label name | Purpose |
|------------|---------|
| `AI ready` | Draft created, waiting for review |
| `info` | No reply needed |
| `ops` | Needs operational work |
| `high` | Urgent / time-sensitive |
| `$` | Invoice / billing context |

After creating them, get their IDs:

```bash
gws gmail users labels list --params '{"userId":"me"}' --format json
```

Update the label IDs in `skills/reply-email/SKILL.md` under "Gmail label IDs".

#### 2c. Set up the calendar

Create a dedicated calendar in Google Calendar (e.g., "My Ops") for the time blocks. Get its ID:

```bash
gws calendar calendarList list --format json
```

Update the calendar ID in `scripts/morning-triage.sh`.

#### 2d. Install the scheduler

```bash
# Edit the plist with your paths
vim launchd/com.claude.morning-triage.plist

# Copy to LaunchAgents
cp launchd/com.claude.morning-triage.plist ~/Library/LaunchAgents/

# Load it
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.claude.morning-triage.plist

# Verify
launchctl list | grep claude.morning-triage
```

## Step 3: Test

```bash
# Run a test triage
./scripts/morning-triage.sh
```

This should:
1. Open an iTerm2 window with a dark navy background
2. Claude Code starts and triages your inbox
3. Drafts appear in your Gmail Drafts folder
4. A calendar event appears in your ops calendar

## Step 4: Teach it your voice

The first few days, drafts won't sound like you. That's expected. The system improves through corrections:

1. **Day 1-3**: Review every draft. Edit heavily in Gmail before sending.
2. **Day 4-7**: Drafts start matching your patterns. Fewer edits needed.
3. **Week 2+**: Most drafts are send-as-is. Occasional corrections for edge cases.

The key file is `skills/reply-email/learned-replies.md` — it accumulates your corrections automatically. After 30 corrections, voice matching is typically good.

## Troubleshooting

### launchd not firing
```bash
# Check if loaded
launchctl list | grep claude.morning-triage

# Check logs
cat ~/Library/Logs/claude-morning-triage/launchd-stderr.log

# Manually trigger
launchctl kickstart gui/$(id -u)/com.claude.morning-triage
```

### gws authentication expired
```bash
gws auth login
```

### Claude Code not found
```bash
which claude
# Should output /usr/local/bin/claude
# If not, add to PATH in the launchd plist
```

### Gmail labels not found
```bash
# List all labels with IDs
gws gmail users labels list --params '{"userId":"me"}' --format json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for l in data.get('labels', []):
    print(f'{l[\"id\"]:30s} {l[\"name\"]}')"
```

### Calendar event not created
```bash
# List your calendars to find the right ID
gws calendar calendarList list --format json
```

## Uninstall

```bash
# Stop the scheduler
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.claude.morning-triage.plist

# Remove the plist
rm ~/Library/LaunchAgents/com.claude.morning-triage.plist

# Remove Gmail labels (optional — do this manually in Gmail Settings)
# Remove the calendar (optional — do this in Google Calendar Settings)
```
