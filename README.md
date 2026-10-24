# IPALint

Swift executable package starter: `IPALint` (entry point) → `IPALintCLI` (ArgumentParser surface and external adapters) → `IPALintKit` (all use-case logic).

## Commands

```sh
# Install the development tools.
mise run setup

# Build and test.
mise run build
mise run test

# Run all checks.
mise run check

# Run the executable.
mise run run
swift run IPALint --version
```
