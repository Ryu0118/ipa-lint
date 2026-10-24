import ArgumentParser
import IPALintKit

/// The root command of the `ipa-lint` executable. Running it without a subcommand runs `lint`.
package struct IPALintCommand: AsyncParsableCommand {
    /// Command name, help text, subcommands, and the `--version` value.
    package static let configuration = CommandConfiguration(
        commandName: "ipa-lint",
        abstract: "Statically checks an .ipa, .xcarchive, or .app for bundled waste, security problems, and review risks.",
        version: IPALintVersion.current,
        subcommands: [LintCommand.self, SnapshotCommand.self, RulesCommand.self],
        defaultSubcommand: LintCommand.self,
    )

    package init() {}
}
