#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.config/waybar/pomodoro"
STATE_FILE="$STATE_DIR/state.json"

# Defaults (override via ~/.config/waybar/pomodoro.conf)
WORK_MIN=25
SHORT_BREAK_MIN=5
LONG_BREAK_MIN=15
CYCLES_BEFORE_LONG=4

# Sound settings
# You can override these in ~/.config/waybar/pomodoro.conf
SOUND_ENABLED=${SOUND_ENABLED:-true}
SOUND_FILE=${SOUND_FILE:-"$HOME/.local/share/waybar/sounds/pomodoro.mp3"}

# Icons (MDI via Nerd Font)
ICON_WORK="󰔟"         # timer-sand
ICON_BREAK="󰄛"        # coffee
ICON_PAUSED="󰏤"       # pause

# Colors are handled in CSS via classes

mkdir -p "$STATE_DIR"

# shellcheck disable=SC1090
[[ -f "$HOME/.config/waybar/pomodoro.conf" ]] && source "$HOME/.config/waybar/pomodoro.conf"

now() { date +%s; }

json_escape() { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    cat "$STATE_FILE"
  else
    printf '{"phase":"idle","running":false,"round":0,"end":0,"remaining":0}'
  fi
}

save_state() { printf '%s' "$1" > "$STATE_FILE"; }

duration_for() {
  case "$1" in
    work) echo $((WORK_MIN*60)) ;;
    break) echo $((SHORT_BREAK_MIN*60)) ;;
    long_break) echo $((LONG_BREAK_MIN*60)) ;;
  esac
}

next_phase_after() {
  # Args: phase round
  local phase="$1" round="$2"
  if [[ "$phase" == "work" ]]; then
    if (( (round % CYCLES_BEFORE_LONG) == 0 )); then echo long_break; else echo break; fi
  else
    echo work
  fi
}

fmt_mmss() {
  local s=$1
  (( s < 0 )) && s=0
  printf '%02d:%02d' $((s/60)) $((s%60))
}

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  local title="$1" body="$2"
  notify-send -a Waybar "$title" "$body" -u normal || true
}

play_sound() {
  [[ "$SOUND_ENABLED" == "true" ]] || return 0
  [[ -f "$SOUND_FILE" ]] || return 0
  if command -v ffplay >/dev/null 2>&1; then
    nohup ffplay -nodisp -autoexit -loglevel error "$SOUND_FILE" >/dev/null 2>&1 & disown || true
  elif command -v pw-play >/dev/null 2>&1; then
    nohup pw-play "$SOUND_FILE" >/dev/null 2>&1 & disown || true
  elif command -v paplay >/dev/null 2>&1; then
    nohup paplay "$SOUND_FILE" >/dev/null 2>&1 & disown || true
  elif command -v canberra-gtk-play >/dev/null 2>&1; then
    # canberra expects a named event; use file if supported
    nohup canberra-gtk-play -f "$SOUND_FILE" >/dev/null 2>&1 & disown || true
  else
    return 0
  fi
}

tick() {
  local st; st=$(load_state)
  local phase running round end remaining
  phase=$(jq -r '.phase' <<<"$st")
  running=$(jq -r '.running' <<<"$st")
  round=$(jq -r '.round' <<<"$st")
  end=$(jq -r '.end' <<<"$st")

  if [[ "$running" != "true" ]]; then
    remaining=$(jq -r '.remaining' <<<"$st")
  else
    local nowts; nowts=$(now)
    remaining=$(( end - nowts ))
    if (( remaining <= 0 )); then
      # Phase complete -> advance
      if [[ "$phase" == "work" ]]; then
        round=$((round+1))
        notify "Pomodoro" "Work session complete (round $round)."
        play_sound
      else
        notify "Pomodoro" "Break complete."
        play_sound
      fi
      phase=$(next_phase_after "$phase" "$round")
      local dur; dur=$(duration_for "$phase")
      end=$(( $(now) + dur ))
      remaining=$dur
      st=$(jq -c --arg ph "$phase" --argjson r "$round" --argjson e "$end" '.phase=$ph|.round=$r|.end=$e|.running=true' <<<"$st")
      save_state "$st"
    fi
  fi

  # Build output JSON
  local icon class label tooltip
  case "$phase" in
    work) icon="$ICON_WORK" ; class="work" ;;
    break|long_break) icon="$ICON_BREAK" ; class="break" ;;
    *) icon="$ICON_PAUSED" ; class="idle" ;;
  esac
  if [[ "$running" != "true" ]]; then class="paused ""$class"; fi
  label="$(fmt_mmss "$remaining")"
  tooltip="Phase: $phase\nRound: $round\nClick: start/pause, Middle: skip, Right: stop"
  printf '{"text":"%s %s","tooltip":"%s","class":"%s"}\n' "$icon" "$label" "$(printf '%s' "$tooltip" | json_escape)" "$class"
}

cmd_start() {
  local st; st=$(load_state)
  local phase running round
  phase=$(jq -r '.phase' <<<"$st")
  running=$(jq -r '.running' <<<"$st")
  round=$(jq -r '.round' <<<"$st")
  if [[ "$phase" == "idle" ]]; then phase=work; fi
  local dur; dur=$(duration_for "$phase")
  local end=$(( $(now) + dur ))
  st=$(jq -c --arg ph "$phase" --argjson r "$round" --argjson e "$end" '.phase=$ph|.round=$r|.end=$e|.running=true|.remaining=0' <<<"$st")
  save_state "$st"
}

cmd_pause() {
  local st; st=$(load_state)
  local running end; running=$(jq -r '.running' <<<"$st") ; end=$(jq -r '.end' <<<"$st")
  if [[ "$running" == "true" ]]; then
    local rem=$(( end - $(now) ))
    (( rem < 0 )) && rem=0
    st=$(jq -c --argjson rem "$rem" '.running=false|.remaining=$rem' <<<"$st")
    save_state "$st"
  fi
}

cmd_toggle() {
  local st; st=$(load_state)
  local running; running=$(jq -r '.running' <<<"$st")
  if [[ "$running" == "true" ]]; then cmd_pause; else cmd_start; fi
}

cmd_stop() {
  save_state '{"phase":"idle","running":false,"round":0,"end":0,"remaining":0}'
}

cmd_skip() {
  local st; st=$(load_state)
  local phase round; phase=$(jq -r '.phase' <<<"$st"); round=$(jq -r '.round' <<<"$st")
  if [[ "$phase" == "work" ]]; then round=$((round+1)); fi
  phase=$(next_phase_after "$phase" "$round")
  local dur; dur=$(duration_for "$phase")
  st=$(jq -c --arg ph "$phase" --argjson r "$round" --argjson e "$(( $(now) + dur ))" '.phase=$ph|.round=$r|.end=$e|.running=true|.remaining=0' <<<"$st")
  save_state "$st"
  # Audible + visual feedback when manually skipping
  local disp_phase="$phase"
  [[ "$disp_phase" == "long_break" ]] && disp_phase="break"
  notify "Pomodoro" "Skipped to $disp_phase."
  play_sound
}

case "${1:-status}" in
  start)  cmd_start ;;
  pause)  cmd_pause ;;
  toggle) cmd_toggle ;;
  stop)   cmd_stop ;;
  skip)   cmd_skip ;;
  *)      tick ;;
esac
