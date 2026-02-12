# AI Workflow Guide for Build/Test

This repository uses GitHub Actions as the primary build validation path.
Local full builds are optional and may be skipped on low-resource machines.

## Source of Truth

- Packaging workflow: `.github/workflows/cloud-build.yml`
- Expected output: uploaded binary artifact from GitHub Actions

## Default AI Behavior

When implementing or modifying code, follow this order:

1. Make code/workflow changes.
2. Push changes to GitHub.
3. Verify `cloud-build` run result on GitHub Actions.
4. Confirm artifact exists and matches expected target name.

Do not introduce extra CI workflows unless explicitly requested.

## Build Targets

- Automatic push/PR build: `linux-x86_64`
- Manual dispatch options:
  - `linux-x86_64`
  - `linux-aarch64`

## Using `gh` CLI (when configured)

If `gh` is available and authenticated, use it for validation:

```bash
gh run list --workflow cloud-build.yml --limit 5
gh run view <run-id> --json name,status,conclusion,jobs,url
gh api repos/<owner>/<repo>/actions/runs/<run-id>/artifacts
gh run download <run-id> -n <artifact-name> -D .artifacts
```

Manual trigger examples:

```bash
gh workflow run cloud-build.yml --ref main -f target=linux-x86_64
gh workflow run cloud-build.yml --ref main -f target=linux-aarch64
```

## Authentication Convention

If the environment provides `.env` with `GH_TOKEN`, load it in shell before `gh` commands:

```bash
set -a
. ./.env
set +a
```

Never print token values in logs or responses.

## Success Criteria

A change is considered build-validated only when all are true:

- `cloud-build` run conclusion is `success`
- target job completed (not skipped)
- expected artifact exists in run artifacts
- artifact can be downloaded successfully

## Failure Handling

- If workflow dispatch returns `403`, report token permission scope issue and continue with push-triggered verification.
- If artifact is missing, treat build as failed even if job appears green.
- If a non-target job fails, remove/disable unrelated triggers instead of ignoring persistent red CI.

## Anti-Detection Policy (P0)

Anti-detection work is a P0 reliability and product-integrity requirement.

- Never treat stealth injection scripts as a production fix.
- Never rely on `evaluateOnNewDocument`, post-load JS patching, or runtime monkey-patching as the final solution.
- Implement fingerprint/automation spoofing in browser source code (WebAPI/CDP/runtime internals) so behavior is correct with zero external patch scripts.
- If temporary script-based probing is used for research, clearly label it as diagnostic-only and non-shipping.

### Required Detection Test Sites

Use these sites as the standard anti-detection validation set:

1. `https://bot.sannysoft.com/`
2. `https://abrahamjuliot.github.io/creepjs/`
3. `https://browserleaks.com/javascript`
4. `https://browserleaks.com/webgl`
5. `https://amiunique.org/fingerprint`

### Acceptance Rule

- Final anti-detection validation must run with no stealth injection scripts.
- Report per-site outcomes and key fingerprint fields (at minimum: webdriver, chrome object/runtime, plugins/mimeTypes, languages/platform/vendor, WebGL vendor/renderer).
