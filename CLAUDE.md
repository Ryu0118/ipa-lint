# ipa-lint

`ipa-lint` statically checks a built iOS app (`.ipa`, `.xcarchive`, or `.app`) for files that should not ship, security problems (ATS exceptions, debug entitlements, embedded secrets), and App Store review risks, and compares a build against a snapshot of a previous one. It never runs or decompiles the app; it reads files, plists, Mach-O headers, and `codesign` output.

Rules live in `Sources/IPALintKit/Rules/` (one type per rule, registered in `RuleCatalog.all`). Rule hits never touch the real app in tests: build a synthetic `.app` tree in a temporary directory. Never commit a real app, its plists, or its entitlements as a fixture. Secret-like test strings are assembled at runtime so gitleaks does not flag the test sources.

The executable product is `ipa-lint`; the targets keep the `IPALint` prefix.

Swift executable package: `IPALint` (`@main` + composition only) → `IPALintCLI` (ArgumentParser surface and external adapters only, tested in `IPALintCLITests`) → `IPALintKit` (all use-case logic and workflow sequencing, tested in `IPALintKitTests`). Swift Testing only.

CLI commands only parse and validate CLI syntax, create a Kit request, call one injected Kit Runner, and present its result. Never put use-case decisions or workflow sequencing in `IPALintCLI`; all such logic belongs in a Runner in `IPALintKit`.

## Development workflow

- `mise run setup` — install tools, configure Git hooks
- `mise run check` — format, lint, AST lint, build, test, docsync
- `mise run test` — run the test suite
- See `.mise.toml` for the full task list (`mise tasks`)
- Git hooks in `.githooks/`: pre-commit runs gitleaks, format, lint, AST lint, docsync; pre-push runs AST lint
- Keep commits small and easy to revert

## Coding rules

Read these before writing or reviewing code. They are the source of truth (`.claude/rules` is a symlink to `.agents/rules`):

- `.agents/rules/coding-rules.md` — SSoT / DRY / SOLID, layering (executable / CLI / Kit), Runners, side effects behind protocols (swift-subprocess via ProcessRunning, FileManagerProtocol), errors, tests
- `.agents/rules/swift-coding.md` — files, access control, comments, abstraction, concurrency, testing conventions
- `.agents/rules/code-review.md` — review and refactoring checklist
- `.agents/rules/lint-and-format.md` — what SwiftFormat, SwiftLint, and the AST linter enforce
- `.agents/rules/workflow.md` — commit size, Git and agent hooks, docsync, CI

Access policy: use `package` for anything shared across modules in this package; `public` only for symbols consumed outside it.
