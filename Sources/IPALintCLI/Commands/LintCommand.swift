import ArgumentParser
import IPALintKit

/// `ipa-lint lint`: runs the rules and exits non-zero when the result fails.
package struct LintCommand: ContextualCommand {
    /// Command name and help text.
    package static let configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Lint an .ipa, .xcarchive, or .app.",
    )

    /// The configuration file looked up in the current directory when `--config` is not given.
    package static let defaultConfigurationName = ".ipa-lint.yml"

    @Argument(help: "The .ipa, .xcarchive, or .app to lint.")
    var input: String

    @Option(name: .shortAndLong, help: "The configuration file. Defaults to ./.ipa-lint.yml when it exists.")
    var config: String?

    @Option(help: "A snapshot from `ipa-lint snapshot` of a previous build, to enable the baseline rules.")
    var baseline: String?

    @Option(help: "Output format.")
    var format: ReportFormat = .text

    @Flag(help: "Fail on warnings too.")
    var strict = false

    package init() {}

    /// Lints the input and writes the report.
    package func run(context: CLIContext) async throws {
        let runner = LintRunner(fileManager: context.fileManager, extractor: context.extractor, entitlementsReader: context.entitlementsReader)
        let request = LintRequest(
            input: context.url(forArgument: input),
            configuration: configurationPath(context: context).map(context.url(forArgument:)),
            baseline: baseline.map(context.url(forArgument:)),
        )
        let report = try await runner.run(request)
        try format.formatter.lines(for: report).forEach(context.output.standardOutput)
        if report.fails(strict: strict) {
            throw ExitStatus.violations
        }
    }

    private func configurationPath(context: CLIContext) -> String? {
        if let config {
            return config
        }
        let path = context.url(forArgument: Self.defaultConfigurationName).path(percentEncoded: false)
        return context.fileManager.fileExists(atPath: path) ? Self.defaultConfigurationName : nil
    }
}
