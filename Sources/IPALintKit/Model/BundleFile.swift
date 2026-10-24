/// A regular file inside the app.
package struct BundleFile: Codable, Equatable, Sendable {
    /// The path relative to the `.app` directory.
    package var path: String
    /// The size in bytes.
    package var size: Int

    package init(path: String, size: Int) {
        self.path = path
        self.size = size
    }
}
