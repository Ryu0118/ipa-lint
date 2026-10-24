import FileManagerProtocol
import Foundation
import IPALintKit

/// Everything a command takes from the outside world. The live value is the only place the CLI reads the process
/// environment and builds real adapters; tests pass their own.
package struct CLIContext: Sendable {
    /// Where the command writes.
    package var output: CLIOutput
    /// The file system.
    package var fileManager: any FileManagerProtocol
    /// Unpacks `.ipa` archives.
    package var extractor: any ArchiveExtracting
    /// Reads bundle entitlements.
    package var entitlementsReader: any EntitlementsReading

    /// The real process output, file system, and command-line tools.
    package static var live: CLIContext {
        CLIContext(
            output: .live,
            fileManager: FileManager.default,
            extractor: DittoArchiveExtractor(),
            entitlementsReader: CodesignEntitlementsReader(),
        )
    }

    package init(
        output: CLIOutput,
        fileManager: some FileManagerProtocol,
        extractor: some ArchiveExtracting,
        entitlementsReader: some EntitlementsReading,
    ) {
        self.output = output
        self.fileManager = fileManager
        self.extractor = extractor
        self.entitlementsReader = entitlementsReader
    }

    /// Resolves a command-line path against the current directory.
    package func url(forArgument path: String) -> URL {
        URL(filePath: path, relativeTo: URL(filePath: fileManager.currentDirectoryPath, directoryHint: .isDirectory)).standardizedFileURL
    }
}
