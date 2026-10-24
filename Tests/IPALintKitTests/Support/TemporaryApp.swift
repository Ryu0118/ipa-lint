import Foundation
@testable import IPALintKit

/// A synthetic `.app` directory in a fresh temporary directory, deleted when the value is released.
final class TemporaryApp: Sendable {
    let root: URL
    let appURL: URL

    init(name: String = "Sample.app") throws {
        root = FileManager.default.temporaryDirectory.appending(path: "ipa-lint-tests-\(UUID().uuidString)")
        appURL = root.appending(path: name)
        try FileManager.default.createDirectory(at: appURL, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    /// Writes `data` at `path` relative to the `.app` directory, creating parent directories.
    func write(_ path: String, data: Data) throws {
        let url = appURL.appending(path: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url)
    }

    /// Writes UTF-8 `text` at `path`.
    func write(_ path: String, text: String) throws {
        try write(path, data: Data(text.utf8))
    }

    /// Writes `count` zero bytes at `path`.
    func write(_ path: String, size count: Int) throws {
        try write(path, data: Data(count: count))
    }

    /// Writes an XML property list at `path`.
    func writePlist(_ path: String, _ plist: [String: Any]) throws {
        try write(path, data: PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0))
    }

    /// Loads the app the way the lint runner does, with `entitlements` keyed by bundle path ("" for the app).
    func contents(entitlements: [String: [String: Any]] = [:]) async throws -> AppContents {
        let reader = StubEntitlementsReader(appURL: appURL, entitlements: entitlements)
        return try await AppLoader(fileManager: FileManager.default, entitlementsReader: reader).load(appURL)
    }
}
