# IPALint

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
