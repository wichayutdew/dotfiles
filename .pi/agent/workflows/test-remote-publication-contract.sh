#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "$root"

ruby -ryaml -e '
  root = ARGV.fetch(0)

  def assert(cond, msg)
    abort(msg) unless cond
  end

  read_prompt = ->(rel) { File.read(File.join(root, rel)) }

  %w[work ticket].each do |id|
    wf = YAML.load_file(File.join(root, "#{id}.workflow.yaml"))
    steps = wf.fetch("steps")

    verify = steps.fetch("verify")
    assert verify.dig("transitions", "passed") == "publish", "#{id}: verify.passed must route to publish"
    assert verify.dig("transitions", "failed") == "implement", "#{id}: verify.failed must route to implement"
    assert verify.dig("transitions", "retry") == "verify", "#{id}: verify.retry must route to verify"
    assert verify.dig("permissions", "mcp") == [], "#{id}: verify must be read-only (empty mcp)"

    publish = steps.fetch("publish")
    assert publish.dig("prompt", "file") == "steps/shared/publish-remote.md", "#{id}: publish prompt must be shared/publish-remote.md"
    assert publish.fetch("agent") == "worker", "#{id}: publish must run as worker"
    assert publish.dig("transitions", "published") == "$done", "#{id}: publish.published must finish workflow"
    tools = publish.dig("permissions", "tools") || []
    assert tools.include?("bash") && tools.include?("mcp"), "#{id}: publish needs bash and mcp tools"
    assert publish.dig("permissions", "bash", "mode") == "unrestricted", "#{id}: publish needs unrestricted bash for gh/glab"
    mcp = publish.dig("permissions", "mcp") || []
    assert mcp.include?("gitlab"), "#{id}: publish needs gitlab mcp for GitLab origins"

    verify_prompt = read_prompt.call(verify.dig("prompt", "file"))
    assert !verify_prompt.downcase.include?("git push"), "#{id}: verify prompt must not push"
    assert !verify_prompt.include?("GitLab MCP"), "#{id}: verify prompt must not mutate GitLab"
    assert !verify_prompt.downcase.include?("merge request"), "#{id}: verify prompt must not create MR/PR"

    plan = YAML.load_file(File.join(root, "#{id}.workflow.yaml"))
    plan_step = plan.fetch("steps").fetch("plan")
    contract = plan_step.fetch("gate").fetch("artifactContract")
    assert contract.fetch("requiredSubstrings").include?("## Publication contract"), "#{id}: plan artifact contract requires publication section"

    plan_prompt = read_prompt.call(plan_step.dig("prompt", "file"))
    assert plan_prompt.include?("## Publication contract"), "#{id}: plan prompt must include publication contract section"
    assert plan_prompt.include?("\"provider\""), "#{id}: plan publication JSON must include provider"
    assert plan_prompt.include?("\"repository\""), "#{id}: plan publication JSON must include repository"
    assert plan_prompt.include?("\"sourceBranch\""), "#{id}: plan publication JSON must include sourceBranch"
    assert plan_prompt.include?("\"targetBranch\""), "#{id}: plan publication JSON must include targetBranch"
    assert plan_prompt.include?("\"descriptionTemplate\""), "#{id}: plan publication JSON must include descriptionTemplate"
    assert plan_prompt.include?("\"sha256\""), "#{id}: plan publication JSON must include template sha256"
  end

  publish_prompt = read_prompt.call("steps/shared/publish-remote.md")
  assert publish_prompt.downcase.include?("origin-derived"), "publish-remote.md: must derive provider from origin"
  assert publish_prompt.include?("non-force"), "publish-remote.md: must forbid force-push"
  assert publish_prompt.include?("git push --set-upstream origin"), "publish-remote.md: must use non-force upstream push"
  assert publish_prompt.include?("gh pr"), "publish-remote.md: must support gh pr for GitHub"
  assert publish_prompt.include?("GitLab MCP") || publish_prompt.include?("glab mr"), "publish-remote.md: must support GitLab MCP or glab mr"
  assert publish_prompt.downcase.include?("sha-256") || publish_prompt.downcase.include?("sha256"), "publish-remote.md: must validate template hash"
  assert publish_prompt.downcase.include?("do not invent"), "publish-remote.md: must not invent description"
  assert publish_prompt.downcase.include?("template-first") || publish_prompt.downcase.include?("template derived"), "publish-remote.md: must be template-first"
  assert publish_prompt.downcase.include?("idempotent"), "publish-remote.md: must be idempotent"
  assert publish_prompt.downcase.include?("existing"), "publish-remote.md: must check for existing review"

  Dir.glob(File.join(root, "*.workflow.yaml")).each do |path|
    YAML.load_file(path)
  end

  puts "ok remote-publication-contract"
' "$root"
