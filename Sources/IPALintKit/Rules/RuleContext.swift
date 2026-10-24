import FileManagerProtocol
import Foundation

/// What a rule can see: the app's files and bundles, its own settings, and the baseline snapshot if one was given.
package struct RuleContext: Sendable {
    /// The files and bundles of the app.
    package var contents: AppContents
    /// The settings the configuration gives this rule.
    package var settings: RuleSettings
    /// The snapshot of a previous build to compare against, if any.
    package var baseline: BundleSnapshot?
    private let fileManager: any FileManagerProtocol

    package init(contents: AppContents, settings: RuleSettings, baseline: BundleSnapshot?, fileManager: some FileManagerProtocol) {
        self.contents = contents
        self.settings = settings
        self.baseline = baseline
        self.fileManager = fileManager
    }

    /// The bytes of the file at `path` (relative to the `.app` directory), or nil when it cannot be read.
    package func data(at path: String) -> Data? {
        fileManager.contents(atPath: contents.rootURL.appending(path: path).path(percentEncoded: false))
    }
}
