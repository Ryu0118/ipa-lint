import Foundation
@testable import IPALintCLI
import IPALintKit
import Testing

struct LintCommandTests {
    struct NoExtractor: ArchiveExtracting {
        func extract(archiveAt _: URL, into _: URL) async throws {}
    }

    struct NoEntitlements: EntitlementsReading {
        func entitlementsData(ofBundleAt _: URL) async throws -> Data? {
            nil
        }
    }

    @Test("lints an .app, prints the text report, and succeeds when nothing fails")
    func lintsApp() async throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "ipa-lint-cli-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let app = root.appending(path: "Sample.app")
        try FileManager.default.createDirectory(at: app, withIntermediateDirectories: true)
        let config = root.appending(path: "empty.yml")
        try Data().write(to: config)
        let recording = RecordingOutput()
        let context = CLIContext(output: recording.output, fileManager: FileManager.default, extractor: NoExtractor(), entitlementsReader: NoEntitlements())

        try await LintCommand.parse([app.path(percentEncoded: false), "--config", config.path(percentEncoded: false)]).run(context: context)

        #expect(recording.standardOutput.last?.hasPrefix("0 errors,") == true)
    }
}
