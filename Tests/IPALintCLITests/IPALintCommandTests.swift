@testable import IPALintCLI
import IPALintKit
import Testing

struct IPALintCommandTests {
    @Test("--version reports the Kit version")
    func versionMatchesKit() {
        #expect(IPALintCommand.configuration.version == IPALintVersion.current)
    }

    @Test("prints the Kit greeting through the injected output")
    func printsGreeting() async throws {
        let recording = RecordingOutput()
        let context = CLIContext(output: recording.output, environment: [:])
        try await IPALintCommand.parse([]).run(context: context)
        #expect(recording.standardOutput == [IPALintKit.greeting()])
        #expect(recording.standardError.isEmpty)
    }
}
