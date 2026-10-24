import ArgumentParser
import Foundation
import IPALintKit

/// `ipa-lint snapshot`: records a build's files and entitlements for later `--baseline` runs.
package struct SnapshotCommand: ContextualCommand {
    /// Command name and help text.
    package static let configuration = CommandConfiguration(
        commandName: "snapshot",
        abstract: "Write a JSON snapshot of an .ipa, .xcarchive, or .app for `lint --baseline`.",
    )

    @Argument(help: "The .ipa, .xcarchive, or .app to record.")
    var input: String

    @Option(name: .shortAndLong, help: "Write the snapshot to this file instead of standard output.")
    var output: String?

    package init() {}

    /// Records the snapshot and writes it.
    package func run(context: CLIContext) async throws {
        let runner = SnapshotRunner(fileManager: context.fileManager, extractor: context.extractor, entitlementsReader: context.entitlementsReader)
        let snapshot = try await runner.run(context.url(forArgument: input))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(snapshot)
        guard let output else {
            context.output.standardOutput(String(decoding: data, as: UTF8.self))
            return
        }
        let path = context.url(forArgument: output).path(percentEncoded: false)
        guard context.fileManager.createFile(atPath: path, contents: data, attributes: nil) else {
            throw ValidationError("Cannot write the snapshot to \(path).")
        }
        context.output.standardError("Wrote snapshot to \(path)")
    }
}
