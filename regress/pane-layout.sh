#!/bin/sh

PATH=/bin:/usr/bin
TERM=screen

[ -z "$TEST_TMUX" ] && TEST_TMUX=$(readlink -f ../tmux)
TMUX="$TEST_TMUX -Ltest -f/dev/null"

$TMUX kill-server 2>/dev/null
$TMUX -f/dev/null new-session -d -x 80 -y 24 || exit 1
$TMUX set-option status off

# test_layout $expected
test_layout()
{
	exp="$1"
	out=$($TMUX display-message -p "#{pane_layout}")

	if [ "$out" != "$exp" ]; then
		echo "Pane layout test failed."
		echo "Expected: '$exp'"
		echo "But got   '$out'"
		exit 1
	fi
}

# Initial: single pane, active
test_layout "[80x24]"

# Split vertical
$TMUX split-window -v
# Top pane (0) is 80x12 @0,0. Bottom pane (1, active) is 80x11 @0,13.
# Natural order: <80x12>;[80x11]@0,13
# Optimized: <80x12>;[-x11]@-,13
test_layout "<80x12>;[-x11]@-,13"

# Select top pane
$TMUX select-pane -t 0
# Optimized: [80x12];<-x11>@-,13
test_layout "[80x12];<-x11>@-,13"

# Split horizontal in top pane
$TMUX split-window -h
# Pane 0: 40x12 @0,0
# Pane 2: 39x12 @41,0 (active)
# Pane 1: 80x11 @0,13
# Optimized: <40x12>;[39x-]@41,-;<80x11>@0,13
test_layout "<40x12>;[39x-]@41,-;<80x11>@0,13"

$TMUX kill-server
exit 0
