/// The parts of a build that later builds are compared against: its files and the entitlements of each bundle.
package struct BundleSnapshot: Codable, Equatable, Sendable {
    /// Every regular file with its size.
    package var files: [BundleFile]
    /// Entitlements keyed by bundle path (empty string for the app itself).
    package var entitlements: [String: [String: PlistValue]]

    /// The total size of every file in bytes.
    package var totalSize: Int {
        files.reduce(0) { $0 + $1.size }
    }

    package init(files: [BundleFile], entitlements: [String: [String: PlistValue]]) {
        self.files = files
        self.entitlements = entitlements
    }

    package init(contents: AppContents) {
        let signed = contents.bundles.filter { !$0.entitlements.isEmpty }
        self.init(
            files: contents.files,
            entitlements: Dictionary(uniqueKeysWithValues: signed.map { ($0.path, $0.entitlements) }),
        )
    }
}
