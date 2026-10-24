@testable import IPALintCLI
import IPALintKit
import Testing

struct IPALintCommandTests {
    @Test("--version reports the Kit version")
    func versionMatchesKit() {
        #expect(IPALintCommand.configuration.version == IPALintVersion.current)
    }

    @Test("runs lint when no subcommand is given")
    func defaultsToLint() throws {
        let command = try IPALintCommand.parseAsRoot(["App.ipa"])
        #expect(command is LintCommand)
    }
}
