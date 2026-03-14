#!/bin/bash
# Interactive setup for Claude Email Assistant

set -euo pipefail

echo "=== Claude Email Assistant Setup ==="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code CLI not found. Install it first:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
fi

if ! command -v gws &> /dev/null; then
    echo "ERROR: gws CLI not found. Install it first:"
    echo "  See: https://github.com/nicholasgasior/gws"
    exit 1
fi

echo "  claude: $(which claude)"
echo "  gws: $(which gws)"
echo ""

# Get project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Project directory: $SCRIPT_DIR"
echo ""

# Get user info
read -p "Your home directory [$HOME]: " USER_HOME
USER_HOME="${USER_HOME:-$HOME}"

read -p "Your timezone [Europe/Prague]: " TIMEZONE
TIMEZONE="${TIMEZONE:-Europe/Prague}"

read -p "Your Google Calendar ID for ops (or 'skip'): " CALENDAR_ID
if [ "$CALENDAR_ID" = "skip" ]; then
    CALENDAR_ID="your_calendar_id@group.calendar.google.com"
    echo "  Skipped. Update scripts/morning-triage.sh manually later."
fi

read -p "Schedule time (24h format, e.g. 0830) [0830]: " SCHEDULE_TIME
SCHEDULE_TIME="${SCHEDULE_TIME:-0830}"
HOUR="${SCHEDULE_TIME:0:2}"
MINUTE="${SCHEDULE_TIME:2:2}"

echo ""
echo "Configuring..."

# Update morning-triage.sh
sed -i '' "s|WORKDIR=.*|WORKDIR=\"$SCRIPT_DIR\"|" scripts/morning-triage.sh
sed -i '' "s|CALENDAR_ID=.*|CALENDAR_ID=\"$CALENDAR_ID\"|" scripts/morning-triage.sh
sed -i '' "s|TIMEZONE=.*|TIMEZONE=\"$TIMEZONE\"|" scripts/morning-triage.sh
chmod +x scripts/morning-triage.sh

# Update launchd plist
PLIST="launchd/com.claude.morning-triage.plist"
sed -i '' "s|/Users/YOU/projects/claude-email-assistant/scripts/morning-triage.sh|$SCRIPT_DIR/scripts/morning-triage.sh|g" "$PLIST"
sed -i '' "s|/Users/YOU/projects/claude-email-assistant|$SCRIPT_DIR|g" "$PLIST"
sed -i '' "s|/Users/YOU/Library|$USER_HOME/Library|g" "$PLIST"
sed -i '' "s|/Users/YOU</string>|$USER_HOME</string>|g" "$PLIST"
# Update schedule time
sed -i '' "s|<integer>8</integer>|<integer>${HOUR#0}</integer>|g" "$PLIST"
sed -i '' "s|<integer>30</integer>|<integer>${MINUTE#0}</integer>|g" "$PLIST"

echo "  Updated scripts/morning-triage.sh"
echo "  Updated launchd plist"

# Create log directory
mkdir -p "$USER_HOME/Library/Logs/claude-morning-triage"
echo "  Created log directory"

# Install launchd agent
echo ""
read -p "Install launchd agent now? (y/n) [y]: " INSTALL_LAUNCHD
INSTALL_LAUNCHD="${INSTALL_LAUNCHD:-y}"

if [ "$INSTALL_LAUNCHD" = "y" ]; then
    cp "$PLIST" "$USER_HOME/Library/LaunchAgents/com.claude.morning-triage.plist"
    launchctl bootstrap gui/$(id -u) "$USER_HOME/Library/LaunchAgents/com.claude.morning-triage.plist" 2>/dev/null || true
    echo "  Installed and loaded launchd agent"
    echo "  Schedule: weekdays at ${HOUR}:${MINUTE}"
else
    echo "  Skipped. Install manually later:"
    echo "    cp $PLIST ~/Library/LaunchAgents/"
    echo "    launchctl bootstrap gui/\$(id -u) ~/Library/LaunchAgents/com.claude.morning-triage.plist"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit skills/reply-email/email-voice-guide.md with 10-20 real emails you've sent"
echo "  2. Edit shared/communication-style.md with your writing rules"
echo "  3. Create Gmail labels: 'AI ready', 'info', 'ops', 'high', '\$'"
echo "  4. Update label IDs in skills/reply-email/SKILL.md"
echo "  5. Test: ./scripts/morning-triage.sh"
echo ""
echo "The system will improve with each correction you make. Give it a week."
