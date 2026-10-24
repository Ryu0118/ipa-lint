import FileManagerProtocol
import Foundation

/// Finds the app and the bundles nested in it, and reads their `Info.plist` and entitlements.
package struct BundleDiscoverer: Sendable {
    private let fileManager: any FileManagerProtocol
    private let entitlementsReader: any EntitlementsReading

    package init(fileManager: some FileManagerProtocol, entitlementsReader: some EntitlementsReading) {
        self.fileManager = fileManager
        self.entitlementsReader = entitlementsReader
    }

    /// The bundles under `root` that have an `Info.plist` among `files`, with the app itself first.
    package func discover(in root: URL, files: [BundleFile]) async throws -> [EmbeddedBundle] {
        var bundles: [EmbeddedBundle] = []
        for (path, kind) in Self.bundleDirectories(in: files) {
            let infoPlist = readPlist(root.appending(path: path).appending(path: "Info.plist"))
            let entitlements = kind == .framework ? [:] : try await readEntitlements(root.appending(path: path))
            bundles.append(EmbeddedBundle(path: path, kind: kind, infoPlist: infoPlist, entitlements: entitlements))
        }
        return bundles
    }

    /// Bundle directories, identified by an `Info.plist` directly inside a directory with a bundle extension.
    static func bundleDirectories(in files: [BundleFile]) -> [(String, BundleKind)] {
        let root: [(String, BundleKind)] = [("", .application)]
        let nested = files.compactMap { file -> (String, BundleKind)? in
            guard file.path.hasSuffix("/Info.plist") else {
                return nil
            }
            let directory = String(file.path.dropLast("/Info.plist".count))
            let name = directory.split(separator: "/").last.map(String.init) ?? directory
            return BundleKind(directoryName: name).map { (directory, $0) }
        }
        return root + nested.sorted { $0.0 < $1.0 }
    }

    private func readPlist(_ url: URL) -> [String: PlistValue] {
        fileManager.contents(atPath: url.path(percentEncoded: false)).flatMap(PlistValue.dictionary(from:)) ?? [:]
    }

    private func readEntitlements(_ bundle: URL) async throws -> [String: PlistValue] {
        try await entitlementsReader.entitlementsData(ofBundleAt: bundle).flatMap(PlistValue.dictionary(from:)) ?? [:]
    }
}
