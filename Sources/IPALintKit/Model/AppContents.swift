import Foundation

/// Everything the rules inspect: the files of an unpacked `.app` and the bundles inside it.
package struct AppContents: Sendable {
    /// The `.app` directory on disk.
    package var rootURL: URL
    /// Every regular file, sorted by path.
    package var files: [BundleFile]
    /// The app and every bundle nested in it, sorted by path.
    package var bundles: [EmbeddedBundle]

    package init(rootURL: URL, files: [BundleFile], bundles: [EmbeddedBundle]) {
        self.rootURL = rootURL
        self.files = files
        self.bundles = bundles
    }
}
