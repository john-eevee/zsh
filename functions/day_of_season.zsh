#!/bin/zsh
# Display current date as day of the current season
# Usage: day_of_season [--south]
# Options:
#   --south   Use southern hemisphere dates (otherwise uses northern)
# Environment:
#   HEMISPHERE  Set to "south" to use southern hemisphere dates
function day_of_season() {
local today=$(date +%s)
local year=$(date +%Y)
local month=$(date +%m)
local day=$(date +%d)

# Determine hemisphere
local hemisphere="north"
[[ $1 == "--south" ]] && hemisphere="south"
[[ $HEMISPHERE == "south" ]] && hemisphere="south"

local season_name
local season_start_epoch

# Northern Hemisphere seasons (default)
if [[ $hemisphere == "north" ]]; then
  if [[ $month -eq 12 && $day -ge 21 ]] || [[ $month -lt 3 ]] || [[ $month -eq 3 && $day -le 20 ]]; then
    season_name="Winter"
    if [[ $month -lt 3 ]] || [[ $month -eq 3 && $day -le 20 ]]; then
      season_start_epoch=$(date -d "$((year - 1))-12-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$((year - 1))-12-21" +%s)
    else
      season_start_epoch=$(date -d "${year}-12-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-12-21" +%s)
    fi
  elif [[ $month -ge 3 && $month -le 5 ]] && ! [[ $month -eq 3 && $day -le 20 ]]; then
    season_name="Spring"
    season_start_epoch=$(date -d "${year}-03-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-03-21" +%s)
  elif [[ $month -ge 6 && $month -le 8 ]] && ! [[ $month -eq 6 && $day -le 20 ]]; then
    season_name="Summer"
    season_start_epoch=$(date -d "${year}-06-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-06-21" +%s)
  else
    season_name="Fall"
    season_start_epoch=$(date -d "${year}-09-23" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-09-23" +%s)
  fi

# Southern Hemisphere seasons (reversed)
else
  if [[ $month -eq 6 && $day -ge 21 ]] || [[ $month -eq 7 ]] || [[ $month -eq 8 ]] || [[ $month -eq 9 && $day -le 22 ]]; then
    season_name="Winter"
    if [[ $month -lt 9 ]] || [[ $month -eq 9 && $day -le 22 ]]; then
      season_start_epoch=$(date -d "$((year - 1))-06-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$((year - 1))-06-21" +%s)
    else
      season_start_epoch=$(date -d "${year}-06-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-06-21" +%s)
    fi
  elif [[ $month -ge 9 && $month -le 11 ]] && ! [[ $month -eq 9 && $day -le 22 ]]; then
    season_name="Spring"
    season_start_epoch=$(date -d "${year}-09-23" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-09-23" +%s)
  elif [[ $month -eq 12 ]] || [[ $month -le 2 ]]; then
    season_name="Summer"
    if [[ $month -le 2 ]]; then
      season_start_epoch=$(date -d "$((year - 1))-12-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$((year - 1))-12-21" +%s)
    else
      season_start_epoch=$(date -d "${year}-12-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-12-21" +%s)
    fi
  else
    season_name="Fall"
    season_start_epoch=$(date -d "${year}-03-21" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-03-21" +%s)
  fi
fi

# Calculate day of season
local day_of_season=$(( (today - season_start_epoch) / 86400 + 1 ))

print "${day_of_season} of ${season_name}"
}
