#!/usr/bin/env bash
# Claude Code status line — Powerlevel10k lean + CHIMERA
# Left:   user@host  cwd  branch
# Right:  model · effort  │  [ctx-bar] %  │  $cost  ⏳ 5h%
input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input"   | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input"  | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input"  | jq -r '.cost.total_cost_usd // empty')
rl=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')

effort_raw=$(jq -r '.effortLevel // empty' ~/.claude/settings.json 2>/dev/null)
case "$effort_raw" in
  low)    effort_sym="○" ;;
  medium) effort_sym="◐" ;;
  high)   effort_sym="●" ;;
  xhigh)  effort_sym="◉" ;;
  max)    effort_sym="⬤" ;;
  *)      effort_sym="" ;;
esac

RESET=$'\033[0m'; DIM=$'\033[2m'
GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; CYAN=$'\033[36m'
SEP="${DIM}│${RESET}"

short_cwd="${cwd/#$HOME/\~}"

git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# Workspace
left="$user@$host  $short_cwd"
[ -n "$git_branch" ] && left="$left  ${CYAN}${git_branch}${RESET}"

# Agent: model · effort
agent="$model"
[ -n "$effort_sym" ] && agent="$agent  ${DIM}${effort_sym} ${effort_raw}${RESET}"

# Context
ctx_section=""
if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")
  filled=$(( (pct + 5) / 10 )); (( filled > 10 )) && filled=10; (( filled < 0 )) && filled=0
  empty=$(( 10 - filled ))
  if   (( pct >= 80 )); then c=$RED
  elif (( pct >= 50 )); then c=$YELLOW
  else                       c=$GREEN; fi
  bar=""
  (( filled > 0 )) && bar=$(printf '█%.0s' $(seq 1 "$filled"))
  (( empty  > 0 )) && bar="$bar$(printf '░%.0s' $(seq 1 "$empty"))"
  ctx_section="${c}[${bar}]${RESET} ${pct}%"
fi

# Budget: cost + rate limit
budget=""
[ -n "$cost" ] && budget="${DIM}\$$(printf '%.2f' "$cost")${RESET}"
[ -n "$rl"   ] && budget="$budget  ⏳ $(printf '%.0f' "$rl")% 5h"

# Assemble right side with separators
right="$agent"
[ -n "$ctx_section" ] && right="$right  $SEP  $ctx_section"
[ -n "$budget"      ] && right="$right  $SEP  $budget"

printf '%s  %s|%s  %s\n' "$left" "$DIM" "$RESET" "$right"
