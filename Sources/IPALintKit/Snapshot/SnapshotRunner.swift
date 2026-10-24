import FileManagerProtocol
import Foundation

/// Records the files and entitlements of an app for later `--baseline` comparisons.
package struct SnapshotRunner: Sendable {
    private let reader: AppReader

    package init(fileManager: some FileManagerProtocol, extractor: some ArchiveExtracting, entitlementsReader: some EntitlementsReading) {
        reader = AppReader(fileManager: fileManager, extractor: extractor, entitlementsReader: entitlementsReader)
    }

    /// The snapshot of `input`.
    package func run(_ input: URL) async throws -> BundleSnapshot {
        try await reader.withContents(of: input) { BundleSnapshot(contents: $0) }
    }
}
