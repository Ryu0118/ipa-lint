import Foundation
import IPALintKit
import ProcessRunning
import Subprocess

/// Unpacks archives with `ditto`, which keeps the symbolic links and permissions inside framework bundles.
package struct DittoArchiveExtractor: ArchiveExtracting {
    private let processRunner: any ProcessRunning

    package init(processRunner: some ProcessRunning = ProcessRunner()) {
        self.processRunner = processRunner
    }

    /// Runs `ditto -x -k <archive> <directory>`.
    package func extract(archiveAt archive: URL, into directory: URL) async throws {
        let result = try await processRunner.run(
            .name("ditto"),
            arguments: ["-x", "-k", archive.path(percentEncoded: false), directory.path(percentEncoded: false)],
            output: .discarded,
            error: .string(limit: 64 * 1024),
        )
        guard result.terminationStatus.isSuccess else {
            throw ToolError.failed(tool: "ditto", status: "\(result.terminationStatus)", message: result.standardError)
        }
    }
}
