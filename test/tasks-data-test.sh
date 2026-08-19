#!/bin/bash

set -euo pipefail

test_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$test_dir/.." && pwd)
helper="$repo_dir/tasks-data"
test_tmp=$(mktemp -d)
mock_bin="$test_tmp/bin"

cleanup() {
  rm -rf -- "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$mock_bin"
ln -s "$(command -v jq)" "$mock_bin/jq"

output=$(PATH="$mock_bin" /bin/bash "$helper")
jq -e '
  .available == false and
  .tuiAvailable == false and
  .readError == false and
  .total == 0 and
  .actionable == 0 and
  (.tooltip | contains("Left-click to install Taskwarrior"))
' <<<"$output" >/dev/null

ln -s "$test_dir/fixtures/task" "$mock_bin/task"

output=$(PATH="$mock_bin" /bin/bash "$helper")
jq -e '
  .available == true and
  .tuiAvailable == false and
  .readError == false and
  .total == 5 and
  .actionable == 2 and
  (.tooltip | contains("Taskwarrior TUI is not installed"))
' <<<"$output" >/dev/null

ln -s "$test_dir/fixtures/taskwarrior-tui" "$mock_bin/taskwarrior-tui"

output=$(PATH="$mock_bin" /bin/bash "$helper")
jq -e '
  .available == true and
  .tuiAvailable == true and
  .readError == false and
  .total == 5 and
  .actionable == 2 and
  (.tooltip | contains("Ship Omarchy Tasks preview")) and
  (.tooltip | contains("Taskwarrior TUI is not installed") | not)
' <<<"$output" >/dev/null

output=$(TASK_FIXTURE_MODE=invalid-counts PATH="$mock_bin" /bin/bash "$helper")
jq -e '
  .available == true and
  .tuiAvailable == true and
  .readError == true and
  .total == 0 and
  .actionable == 0 and
  (.tooltip | contains("Taskwarrior data could not be read"))
' <<<"$output" >/dev/null

output=$(TASK_FIXTURE_MODE=failure PATH="$mock_bin" /bin/bash "$helper")
jq -e '
  .available == true and
  .tuiAvailable == true and
  .readError == true and
  .total == 0 and
  .actionable == 0 and
  (.tooltip | contains("Taskwarrior data could not be read"))
' <<<"$output" >/dev/null

output=$(TASK_FIXTURE_MODE=escaped PATH="$mock_bin" /bin/bash "$helper")
jq -e '
  .available == true and
  .readError == false and
  (.tooltip | contains("Review \"quoted\" task \\ path")) and
  (.tooltip | contains("Preserve a second line"))
' <<<"$output" >/dev/null

printf 'tasks-data tests passed\n'
