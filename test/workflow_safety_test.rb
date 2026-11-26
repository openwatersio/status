require "minitest/autorun"
require "yaml"

class WorkflowSafetyTest < Minitest::Test
  def workflow(name)
    YAML.load_file(".github/workflows/#{name}.yml")
  end

  def test_template_updates_cannot_run_on_default_branch
    update = workflow("update-template")
    assert_equal ["workflow_dispatch"], update.fetch(true).keys
    assert_equal "${{ github.ref_name != github.event.repository.default_branch }}", update.dig("jobs", "release", "if")
  end

  def test_setup_does_not_regenerate_live_workflows
    steps = workflow("setup").dig("jobs", "release", "steps")
    refute steps.any? { |step| step.dig("with", "command") == "update-template" }
  end

  def test_uptime_remains_scheduled_every_five_minutes
    assert_equal "*/5 * * * *", workflow("uptime").dig(true, "schedule", 0, "cron")
  end
end
