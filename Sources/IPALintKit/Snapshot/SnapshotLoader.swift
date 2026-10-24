import FileManagerProtocol
import Foundation

/// Reads a snapshot written by `ipa-lint snapshot`.
package struct SnapshotLoader: Sendable {
    private let fileManager: any FileManagerProtocol

    package init(fileManager: some FileManagerProtocol) {
        self.fileManager = fileManager
    }

    /// Decodes the snapshot JSON at `url`.
    package func load(_ url: URL) throws -> BundleSnapshot {
        let path = url.path(percentEncoded: false)
        guard let data = fileManager.contents(atPath: path) else {
            throw SnapshotError.unreadable(path)
        }
        do {
            return try JSONDecoder().decode(BundleSnapshot.self, from: data)
        } catch {
            throw SnapshotError.invalid(path: path, detail: String(describing: error))
        }
    }
}
