# Maintaining the status workflows

The Upptime workflows use `.github/workflows/actions.lock` to pin their actions. Run `gh actions-lock --no-narrow` after changing workflow action references, and review the resulting workflow and lockfile changes together. Install the extension with `gh extension install github/gh-actions-lock`.

Upptime's template updater rewrites all eight generated workflows and pushes its changes. Run it on a branch and review those changes in a pull request; the updater refuses to run on the default branch. It is not scheduled. Setup CI still refreshes status data after `.upptimerc.yml` changes, but does not regenerate the workflows, so changes to generated workflow settings also need a template update PR.

The updater and the daily updates action both use `master` references. The runner executes the commits in `actions.lock`, even when those branches advance. Before running a template update, review and advance those commits in a separate pull request: run `gh actions-lock --relock .github/workflows/update-template.yml .github/workflows/updates.yml`, inspect every changed action commit and repository identity, and merge that PR. The command can also advance shared action pins used by other workflows. Investigate unreachable or moved-history errors; do not automatically accept them.

Then update the template:

1. Create a branch from the latest `master`, push it, and run `gh workflow run update-template.yml --ref <branch>`. Wait for the run to finish.
2. Fetch and check out the updated branch. Restore `.github/workflows/update-template.yml` from `origin/master`: Upptime regenerates that file with a schedule that would otherwise push directly to the live branch.
3. In the generated `.github/workflows/setup.yml`, remove the `Update template` step. Review the rest of Upptime's changes, including any configuration-dependent workflow changes.
4. Run `gh actions-lock --no-narrow` and `ruby test/workflow_safety_test.rb`. Commit the results and open a pull request. Check the lockfile's action commits and repository identities as part of review.

The five-minute uptime workflow continues writing status history directly to `master`, so the lockfile verifier is not a required branch check. Watch its result when reviewing a pull request.
