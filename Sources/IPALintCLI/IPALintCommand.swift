import ArgumentParser
import IPALintKit

/// The root command of the `IPALint` executable.
package struct IPALintCommand: ContextualCommand {
    /// Command name, help text, and the `--version` value.
    package static let configuration = CommandConfiguration(
        commandName: "IPALint",
        abstract: "IPALint command-line tool.",
        version: IPALintVersion.current
    )

    package init() {}

    /// Prints the starter greeting.
    package func run(context: CLIContext) async throws {
        context.output.standardOutput(IPALintKit.greeting())
    }
}
