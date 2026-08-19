#!/bin/bash

set -euo pipefail

test_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
widget="$test_dir/../BarWidget.qml"

assert_contains() {
  local expected=$1

  if ! grep -Fq -- "$expected" "$widget"; then
    printf 'BarWidget.qml is missing expected behavior:\n%s\n' "$expected" >&2
    exit 1
  fi
}

assert_contains 'property bool taskReadError: false'
assert_contains 'root.taskReadError = data.readError === true'
assert_contains 'visible: !taskwarriorAvailable || !taskwarriorTuiAvailable || taskReadError || total > 0 || showWhenEmpty'
assert_contains 'text: root.taskwarriorAvailable && !root.taskReadError'
assert_contains 'active: root.actionable > 0 || !root.taskwarriorAvailable || !root.taskwarriorTuiAvailable || root.taskReadError'
assert_contains 'dimmed: root.taskwarriorAvailable && root.taskwarriorTuiAvailable && !root.taskReadError && root.total === 0'
assert_contains 'omarchy launch floating terminal with presentation \"omarchy pkg add task taskwarrior-tui && omarchy-shell io.github.janhesters.tasks refresh\"'
assert_contains 'omarchy launch floating terminal with presentation \"omarchy pkg add taskwarrior-tui && omarchy-shell io.github.janhesters.tasks refresh\"'

printf 'BarWidget state tests passed\n'
