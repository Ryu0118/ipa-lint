import Foundation

/// The `.app` directory an input path resolved to.
package struct ResolvedInput: Equatable, Sendable {
    /// The `.app` directory to inspect.
    package var appURL: URL
    /// A temporary directory the input was unpacked into, to delete when done.
    package var temporaryDirectory: URL?

    package init(appURL: URL, temporaryDirectory: URL?) {
        self.appURL = appURL
        self.temporaryDirectory = temporaryDirectory
    }
}
