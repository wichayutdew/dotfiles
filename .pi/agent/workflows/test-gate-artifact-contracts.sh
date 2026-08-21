#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ruby -ryaml -e '
  expected = {
    "investigate.workflow.yaml" => [6000, ["## Brief description", "## Goals", "## Boundaries", "## Evidence & sources", "## Report destination", "## Open evidence gaps"]],
    "work.workflow.yaml" => [8000, ["## Review summary", "## Review focus", "## Proposed approach", "## Validation", "## Risks", "## Execution appendix (machine-readable)"]],
    "ticket.workflow.yaml" => [10000, ["## Review summary", "## Review focus", "## Proposed approach", "## Validation", "## Risks", "## Execution appendix (machine-readable)", "## Publication contract"]],
    "jira.workflow.yaml" => [16000, ["# Create Jira Epic and Stories", "## Jira field contract", "## Epic", "## Ordered Stories", "## Creation sequence", "## Safety limits"]],
    "mr-comment.workflow.yaml" => [10000, ["## Review summary", "## Comment decisions", "## Implementation plan", "## Validation", "## Replies and remote actions", "## Risks", "## Execution appendix (machine-readable)"]],
    "mr-review.workflow.yaml" => [8000, ["# Review:", "## Verdict", "## Findings", "## Validation", "## Publication contract", "## Safety boundaries"]],
    "sprint-triage.workflow.yaml" => [20000, ["# Publish reviewed sprint triage knowledge", "## Collection Ledger", "## Draft Summaries", "## Submitted evidence capture", "## Evidence and coverage", "## Approved local content", "## Approved GitLab action", "## Approved Confluence action"]],
  }
  expected.each do |file, (max_chars, headings)|
    workflow = YAML.load_file(File.join(ARGV.fetch(0), file))
    step = workflow.fetch("steps").values.find { |candidate| candidate["gate"] }
    contract = step.fetch("gate").fetch("artifactContract")
    abort "#{file}: maxChars mismatch" unless contract.fetch("maxChars") == max_chars
    abort "#{file}: path-only artifact is not forbidden" unless contract.fetch("forbiddenSubstrings").include?("The complete gate artifact is the exact Markdown saved at")
    abort "#{file}: artifact validation does not retry" unless contract.fetch("onValidationFailure") == "retry"
    headings.each { |heading| abort "#{file}: missing #{heading}" unless contract.fetch("requiredSubstrings").include?(heading) }
  end
' "$root"
