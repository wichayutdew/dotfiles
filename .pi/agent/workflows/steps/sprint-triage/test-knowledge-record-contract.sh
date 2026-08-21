#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

require() {
  local file=$1
  local text=$2
  if ! grep -Fqi "$text" "$root/$file"; then
    echo "$file must require: $text" >&2
    exit 1
  fi
}

require draft.md 'primary source for LLM agents'
require draft.md 'human triage location'
require plan.md 'primary source for LLM agents'
require plan.md 'all five Knowledge-Base Record fields for every summarized ticket'
require verify.md 'primary source for LLM agents'
require verify.md 'all five Knowledge-Base Record fields'
require verify.md 'every summarized ticket'
require draft.md '**Slack URL:**'
require draft.md '**Steps to take an action to resolve the inquiry:**'

workflow="$root/../../sprint-triage.workflow.yaml"
ruby -ryaml -e '
  gate = YAML.load_file(ARGV.fetch(0)).fetch("steps").fetch("plan").fetch("gate")
  contract = gate.fetch("artifactContract")
  abort "maxChars mismatch" unless contract.fetch("maxChars") == 20_000
  abort "artifact validation does not retry" unless contract.fetch("onValidationFailure") == "retry"
  required = contract.fetch("requiredSubstrings")
  ["# Publish reviewed sprint triage knowledge", "## Collection Ledger", "## Draft Summaries", "## Submitted evidence capture", "## Evidence and coverage", "## Approved local content", "## Approved GitLab action", "## Approved Confluence action"].each do |heading|
    abort "missing required heading: #{heading}" unless required.include?(heading)
  end
  forbidden = contract.fetch("forbiddenSubstrings")
  abort "path-only artifact is not forbidden" unless forbidden.include?("The complete gate artifact is the exact Markdown saved at")
  expected_groups = [
    ["**Inquiry topic:**", "**Steps to take an action to resolve the inquiry:**"],
  ]
  abort "record and guide field groups missing" unless contract.fetch("equalOccurrenceGroups") == expected_groups
' "$workflow"
