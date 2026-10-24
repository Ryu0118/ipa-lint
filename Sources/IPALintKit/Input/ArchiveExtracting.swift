import Foundation

/// Unpacks a zip archive such as an `.ipa`.
package protocol ArchiveExtracting: Sendable {
    /// Extracts the archive at `archive` into the existing directory `directory`.
    func extract(archiveAt archive: URL, into directory: URL) async throws
}
