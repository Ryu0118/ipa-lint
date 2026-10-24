import FileManagerProtocol
import Foundation

/// Reads an unpacked `.app` directory into `AppContents`.
package struct AppLoader: Sendable {
    private let scanner: FileScanner
    private let discoverer: BundleDiscoverer

    package init(fileManager: some FileManagerProtocol, entitlementsReader: some EntitlementsReading) {
        scanner = FileScanner(fileManager: fileManager)
        discoverer = BundleDiscoverer(fileManager: fileManager, entitlementsReader: entitlementsReader)
    }

    /// Lists the files under `appURL` and discovers its bundles.
    package func load(_ appURL: URL) async throws -> AppContents {
        let files = try scanner.scan(appURL)
        let bundles = try await discoverer.discover(in: appURL, files: files)
        return AppContents(rootURL: appURL, files: files, bundles: bundles)
    }
}
