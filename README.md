# 🔍 ipa-lint

[![Language](https://img.shields.io/badge/Language-Swift-F05138?style=flat-square)](https://www.swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey?style=flat-square)](https://github.com/Ryu0118/ipa-lint/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-007ec6?style=flat-square)](LICENSE)

**Catch what should never ship before your build reaches App Store Connect.**

`ipa-lint` is a static linter for built iOS apps. Point it at an `.ipa`, `.xcarchive`, or `.app` and it reports test data and source files in the bundle, weakened security settings, embedded secrets, and binaries App Review rejects. It runs in seconds, needs no source code, and fits between archive and upload in any CI.

## Features

- 🗑️ **Find what should not ship** — test fixtures, source files, duplicated resources, and oversized assets
- 🔐 **Stop security and review regressions** — ATS exceptions, development entitlements, embedded keys, and simulator slices
- 📈 **Compare against the last release** — new files, new entitlements, and size growth since a saved snapshot

## Installation

```bash
mise use -g github:Ryu0118/ipa-lint
```

### Build from source

```bash
git clone https://github.com/Ryu0118/ipa-lint
cd ipa-lint
swift build -c release
cp .build/release/ipa-lint /usr/local/bin/
```

---

## Quick start

1. Lint a build:

   ```bash
   ipa-lint build/MyApp.ipa
   ```

   ```
   error: [dev-artifact] mock-data.json: Development artifact ships in the app; exclude it from the Release build or target membership, or allow it in .ipa-lint.yml with a reason.
   warning: [duplicate-resource] Intro.bundle/animation.json: Identical content is bundled 3 times (also at PlugIns/Widget.appex/Intro.bundle/animation.json, …), wasting 1048576 bytes; keep a single copy or allow it in .ipa-lint.yml with a reason.
   1 error, 1 warning, 0 suppressed
   ```

2. Keep files that must ship by allowing them with a reason in `.ipa-lint.yml`:

   ```yaml
   allow:
     - rule: dev-artifact
       path: "mock-data*.json"
       reason: Demo mode reads it at runtime
   ```

---

## Configuration

`ipa-lint` reads `.ipa-lint.yml` from the current directory, or the file passed with `--config`.

```yaml
disabled_rules:
  - insecure-url

rules:
  large-file:
    severity: error
    max_bytes: 5242880
  duplicate-resource:
    min_bytes: 65536

allow:
  - path: "Frameworks/MyKit.framework"   # no `rule`: allow every rule for this path
    reason: First-party framework; its privacy manifest lives in the app
```

- A `path` without `/` matches the file name anywhere in the app; a `path` with `/` matches from the `.app` root, and `*` matches across directories.
- Every `allow` entry needs a `reason`. An entry that no longer matches anything is reported as `stale-allow`.

---

## Rules

| Rule | Default | Flags |
|---|---|---|
| `dev-artifact` | error | Test plans, `mock-*` files, `Fixtures`/`TestData`/`Preview Content`/`__Snapshots__` directories |
| `source-file` | error | Source, tooling, and backup files (`.swift`, `.md`, `.yml`, `Podfile`, `.DS_Store`, `.backup`, …) |
| `framework-headers` | warning | `Headers`, `PrivateHeaders`, and `Modules` inside embedded frameworks |
| `duplicate-resource` | warning | Files with identical content bundled more than once (`min_bytes`, default 10 KB) |
| `large-file` | warning | Resources over `max_bytes` (default 2 MB), excluding binaries and `Assets.car` |
| `credential-file` | error | `.p8`, `.p12`, `.pem`, `.env`, SSH keys, and stray provisioning profiles |
| `ats-exception` | error | `NSAllowsArbitraryLoads*` and domains that allow plain HTTP |
| `debug-entitlement` | error | `get-task-allow`, and development push, iCloud, or App Attest environments |
| `embedded-secret` | error | AWS, GitHub, Slack, Stripe, OpenAI, and Anthropic keys, and private key blocks |
| `insecure-url` | warning | `http://` URLs to localhost or private networks, and staging hosts (outside third-party frameworks) |
| `missing-privacy-manifest` | warning | The app or a framework without `PrivacyInfo.xcprivacy` |
| `simulator-slice` | error | `x86_64`/`i386` slices and simulator platforms in any binary |
| `min-os-mismatch` | warning | App extensions whose `MinimumOSVersion` differs from the app's |
| `new-file` | warning | Files not in the baseline snapshot |
| `new-entitlement` | warning | Entitlements added or changed since the baseline |
| `size-growth` | warning | Total or per-file growth over `max_bytes` (default 1 MB) since the baseline |
| `stale-allow` | warning | `allow` entries that match nothing |

Google API keys (`AIza…`) are not reported: Firebase ships them in `GoogleService-Info.plist` by design.

---

## Comparing with a previous build

```bash
ipa-lint snapshot build/MyApp-1.4.0.ipa --output release-1.4.0.json
ipa-lint lint build/MyApp.ipa --baseline release-1.4.0.json
```

---

## CI integration

```yaml
- name: Lint the IPA
  run: ipa-lint lint build/MyApp.ipa --format github
```

---

## Command reference

```
ipa-lint [lint] <input> [--config <path>] [--baseline <path>] [--format text|json|github] [--strict]
ipa-lint snapshot <input> [--output <path>]
ipa-lint rules
```

| Flag | Description |
|---|---|
| `--config`, `-c` | Configuration file (default: `./.ipa-lint.yml` when present) |
| `--baseline` | Snapshot from `ipa-lint snapshot` that enables the baseline rules |
| `--format` | `text` (default), `json`, or `github` for workflow annotations |
| `--strict` | Fail on warnings too |

---

## License

MIT. See [LICENSE](LICENSE).
