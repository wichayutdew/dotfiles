#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ruby -ryaml -e '
  def assert(c,m); abort(m) unless c end
  root=ARGV.fetch(0); wf=YAML.load_file(File.join(root,"work.workflow.yaml")); steps=wf.fetch("steps")
  assert(!File.exist?(File.join(root,"ticket.workflow.yaml")), "ticket workflow must be removed")
  plan=steps.fetch("plan"); prompt=File.read(File.join(root,plan.dig("prompt","file")))
  %w[Goal/Acceptance\ Criteria Non\ Goal Implementation\ Steps\ and\ Tests Validation Risks/Decisions\ Needed Publications\ Contract/Metadata Execution\ appendix].each { |s| assert(prompt.include?(s.gsub("\\ "," ")), "plan missing #{s}") }
  assert(plan.dig("permissions","mcp").include?("atlassian"), "plan needs Jira read")
  prep=File.read(File.join(root,"steps/shared/prepare-workspace.md")); assert(prep.include?("semantic-kebab-summary") && prep.include?("random"), "branch contract missing")
  pub=File.read(File.join(root,"steps/shared/publish-remote.md")); assert(!pub.include?("update its title to the approved title"), "existing title must not update")
  assert(pub.include?("<!-- pi-workflow:implementation:start -->") && pub.include?("<!-- ai-only-start -->"), "marker pairs missing")
  assert(pub.include?("mixed") && pub.include?("Preserve every byte outside"), "description preservation missing")
  Dir.glob(File.join(root,"*.workflow.yaml")).each { |p| YAML.load_file(p) }
  puts "ok remote-publication-contract"
' "$root"
