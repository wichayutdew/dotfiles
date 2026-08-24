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
    assert mcp.include?("github/pull_request_read"), "#{id}: publish needs github/pull_request_read for GitHub origins"
    assert mcp.include?("github/create_pull_request"), "#{id}: publish needs github/create_pull_request for GitHub origins"
    assert mcp.include?("github/update_pull_request"), "#{id}: publish needs github/update_pull_request for existing GitHub reviews"
    assert !mcp.include?("github"), "#{id}: publish must not grant server-wide GitHub permission"

    verify_prompt = read_prompt.call(verify.dig("prompt", "file"))
    assert !verify_prompt.downcase.include?("git push"), "#{id}: verify prompt must not push"
    assert !verify_prompt.include?("GitLab MCP"), "#{id}: verify prompt must not mutate GitLab"
    assert !verify_prompt.downcase.include?("merge request"), "#{id}: verify prompt must not create MR/PR"

    plan = YAML.load_file(File.join(root, "#{id}.workflow.yaml"))
    plan_step = plan.fetch("steps").fetch("plan")
    contract = plan_step.fetch("gate").fetch("artifactContract")
    assert contract.fetch("requiredSubstrings").include?("## Publication contract"), "#{id}: plan artifact contract requires publication section"

    plan_mcp = plan_step.dig("permissions", "mcp") || []
    assert plan_mcp.include?("github/get_file_contents"), "#{id}: plan needs GitHub file read capability"
    assert plan_mcp.include?("gitlab"), "#{id}: plan needs GitLab read capability"
    assert !plan_mcp.include?("github"), "#{id}: plan must not grant server-wide GitHub permission"

    plan_prompt = read_prompt.call(plan_step.dig("prompt", "file"))
    assert plan_prompt.include?("## Publication contract"), "#{id}: plan prompt must include publication contract section"
    assert plan_prompt.include?("\"provider\""), "#{id}: plan publication JSON must include provider"
    assert plan_prompt.include?("\"repository\""), "#{id}: plan publication JSON must include repository"
    assert plan_prompt.include?("\"sourceBranch\""), "#{id}: plan publication JSON must include sourceBranch"
    assert plan_prompt.include?("\"targetBranch\""), "#{id}: plan publication JSON must include targetBranch"
    assert plan_prompt.include?("\"descriptionTemplate\""), "#{id}: plan publication JSON must include descriptionTemplate"
    assert plan_prompt.include?("\"sha256\""), "#{id}: plan publication JSON must include template sha256"
    assert plan_prompt.include?("\"source\""), "#{id}: plan publication JSON must include descriptionTemplate source"
    assert plan_prompt.include?("observed `origin`"), "#{id}: plan must record provider, repository, and target branch from observed origin"
    assert plan_prompt.include?("default target branch"), "#{id}: plan must record default target branch from observed origin"
    assert plan_prompt.include?("repository-file"), "#{id}: plan publication must support repository-file description source"
    assert plan_prompt.include?("gitlab-server-default"), "#{id}: plan publication must support gitlab-server-default description source"
    assert plan_prompt.include?("\"none\""), "#{id}: plan publication must support explicit none description source"

    # semantic title grammar: type(scope)!?: brief description
    assert plan_prompt.downcase.include?("conventional commits") || plan_prompt.include?("feat(scope)"), "#{id}: plan prompt must define semantic title grammar"
    %w[feat fix perf refactor docs test build ci chore].each do |type|
      assert plan_prompt.include?("`#{type}`"), "#{id}: plan prompt must list #{type} as permitted type"
    end
    assert plan_prompt.include?("type(scope)!?: brief description"), "#{id}: plan prompt must show semantic title pattern"

    if id == "ticket"
      assert plan_prompt.include?("jiraTicket"), "ticket: plan prompt must require jiraTicket evidence"
      assert plan_prompt.include?("[KEY]"), "ticket: plan prompt must require bracketed Jira key in title"
    else
      assert plan_prompt.include?("jiraTicket"), "work: plan prompt must set jiraTicket to null"
      assert plan_prompt.include?("null"), "work: plan prompt must not invent a Jira key"
    end
  end

  publish_prompt = read_prompt.call("steps/shared/publish-remote.md")
  assert publish_prompt.downcase.include?("origin-derived"), "publish-remote.md: must derive provider from origin"
  assert publish_prompt.include?("GitHub MCP"), "publish-remote.md: must use GitHub MCP for GitHub origins"
  assert publish_prompt.include?("GitLab MCP"), "publish-remote.md: must use GitLab MCP for GitLab origins"
  assert publish_prompt.downcase.include?("unsupported") && publish_prompt.downcase.include?("ambiguous"), "publish-remote.md: must block unsupported or ambiguous hosts"
  assert publish_prompt.include?("only when the required MCP operation is unavailable"), "publish-remote.md: CLI fallback only when MCP lacks operation"
  assert publish_prompt.include?("non-force"), "publish-remote.md: must forbid force-push"
  assert publish_prompt.include?("git push --set-upstream origin"), "publish-remote.md: must use non-force upstream push"
  assert publish_prompt.include?("gh pr"), "publish-remote.md: must support gh pr for GitHub"
  assert publish_prompt.include?("GitLab MCP") || publish_prompt.include?("glab mr"), "publish-remote.md: must support GitLab MCP or glab mr"
  assert publish_prompt.downcase.include?("sha-256") || publish_prompt.downcase.include?("sha256"), "publish-remote.md: must validate template hash"
  assert publish_prompt.downcase.include?("do not invent"), "publish-remote.md: must not invent description"
  assert publish_prompt.downcase.include?("template-first") || publish_prompt.downcase.include?("template derived"), "publish-remote.md: must be template-first"
  assert publish_prompt.downcase.include?("idempotent"), "publish-remote.md: must be idempotent"
  assert publish_prompt.downcase.include?("existing"), "publish-remote.md: must check for existing review"
  assert publish_prompt.include?("repository-file"), "publish-remote.md: must branch repository-file source"
  assert publish_prompt.include?("gitlab-server-default"), "publish-remote.md: must branch gitlab-server-default source"
  assert publish_prompt.include?("\"none\""), "publish-remote.md: must branch explicit none source"
  assert publish_prompt.downcase.include?("omit the description") || publish_prompt.downcase.include?("description argument omitted"), "publish-remote.md: must omit description argument for gitlab-server-default"
  assert publish_prompt.include?("retrieve") && publish_prompt.downcase.include?("returned description"), "publish-remote.md: must retrieve returned MR description"
  assert publish_prompt.downcase.include?("sha-256") && publish_prompt.downcase.include?("exact"), "publish-remote.md: must hash exact returned description bytes"
  assert publish_prompt.include?("update its title to the approved title"), "publish-remote.md: must update an existing review title to the approved title"
  assert publish_prompt.include?("only when `descriptionTemplate.source` is `repository-file`"), "publish-remote.md: must only update an existing review description from a repository template"
  assert publish_prompt.include?("Do not replace an existing description for `none` or `gitlab-server-default`."), "publish-remote.md: must preserve existing descriptions for none and server defaults"

  # title validation must occur before any existing-review lookup, push, or MR creation
  title_section = publish_prompt[/## .*title.*/im, 0]
  assert title_section, "publish-remote.md: must have a title validation section"
  assert publish_prompt.downcase.include?("validate the title"), "publish-remote.md: must validate the approved title"
  assert publish_prompt.include?("Conventional Commit"), "publish-remote.md: must require Conventional Commit style"
  assert publish_prompt.include?("type(scope)!?: brief description"), "publish-remote.md: must enforce semantic title pattern"

  # verify ordering: title validation section appears before idempotent push/MR sections
  title_idx = publish_prompt =~ /## .*title.*/i
  idempotent_idx = publish_prompt =~ /## Idempotent publication/i
  existing_idx = publish_prompt.downcase =~ /existing.*review|check for an existing/
  push_idx = publish_prompt =~ /git push --set-upstream origin/
  create_idx = publish_prompt =~ /If no open review exists, create exactly one PR\/MR/i
  assert title_idx && idempotent_idx && title_idx < idempotent_idx, "publish-remote.md: title validation must precede idempotent publication section"
  assert title_idx && existing_idx && title_idx < existing_idx, "publish-remote.md: title validation must precede existing-review check"
  assert title_idx && push_idx && title_idx < push_idx, "publish-remote.md: title validation must precede push"
  assert title_idx && create_idx && title_idx < create_idx, "publish-remote.md: title validation must precede MR/PR creation"

  # ticket-specific Jira key validation
  assert publish_prompt.include?("[KEY]"), "publish-remote.md: must reference bracketed Jira key for ticket"
  assert publish_prompt.include?("jiraTicket"), "publish-remote.md: must validate approved jiraTicket for ticket"

  # sprint-triage plan and publish must enforce a semantic MR title
  triage_plan = read_prompt.call("steps/sprint-triage/plan.md")
  assert triage_plan.include?("type(scope)!?: brief description"), "sprint-triage plan: must require semantic MR title"
  assert triage_plan.downcase.include?("do not select a representative ticket"), "sprint-triage plan: must not invent a Jira key"

  triage_publish = read_prompt.call("steps/sprint-triage/publish.md")
  assert triage_publish.include?("type(scope)!?: brief description"), "sprint-triage publish: must enforce semantic MR title"
  assert triage_publish.downcase.include?("validate the title"), "sprint-triage publish: must validate MR title"
  triage_title_idx = triage_publish =~ /validate the title/i
  triage_push_idx = triage_publish.index(/Push the committed local branch/i, triage_title_idx)
  triage_mr_idx = triage_publish.index(/Create the single approved MR/i, triage_title_idx)
  assert triage_title_idx && triage_push_idx, "sprint-triage publish: must locate push after title validation"
  assert triage_title_idx && triage_mr_idx, "sprint-triage publish: must locate MR creation after title validation"
  assert triage_title_idx < triage_push_idx, "sprint-triage publish: title validation must precede push"
  assert triage_title_idx < triage_mr_idx, "sprint-triage publish: title validation must precede MR creation"

  Dir.glob(File.join(root, "*.workflow.yaml")).each do |path|
    YAML.load_file(path)
  end

  puts "ok remote-publication-contract"
' "$root"
