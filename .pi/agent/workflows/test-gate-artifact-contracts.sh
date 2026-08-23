#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ruby -ryaml -e '
  expected = {
    "investigate.workflow.yaml" => [6000, ["## Brief description", "## Goals", "## Boundaries", "## Evidence & sources", "## Report destination", "## Open evidence gaps"]],
    "work.workflow.yaml" => [8000, ["## Review summary", "## Review focus", "## Proposed approach", "## Validation", "## Risks", "## Execution appendix (machine-readable)", "## Publication contract"]],
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

  mr_review = YAML.load_file(File.join(ARGV.fetch(0), "mr-review.workflow.yaml"))
  expected_github_tools = {
    "fetch" => ["github/pull_request_read"],
    "review" => ["github/pull_request_read"],
    "publish" => ["github/pull_request_review_write", "github/add_comment_to_pending_review"],
    "verify" => ["github/pull_request_read"],
  }
  expected_github_tools.each do |step_name, tools|
    allowed = mr_review.fetch("steps").fetch(step_name).fetch("permissions").fetch("mcp")
    abort "mr-review #{step_name}: server-wide GitHub permission" if allowed.include?("github")
    tools.each { |tool| abort "mr-review #{step_name}: missing #{tool}" unless allowed.include?(tool) }
  end

  %w[fetch review-for-approval publish-approved verify-published].each do |name|
    prompt = File.read(File.join(ARGV.fetch(0), "steps", "mr-review", "#{name}.md"))
    abort "mr-review #{name}: missing gh api fallback" unless prompt.include?("gh api")
    abort "mr-review #{name}: missing glab api fallback" unless prompt.include?("glab api")
  end
' "$root"
