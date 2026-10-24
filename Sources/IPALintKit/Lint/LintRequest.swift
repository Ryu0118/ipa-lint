import Foundation

/// What to lint and with which configuration.
package struct LintRequest: Equatable, Sendable {
    /// The `.ipa`, `.xcarchive`, or `.app` to inspect.
    package var input: URL
    /// The `.ipa-lint.yml` file, or nil for the defaults.
    package var configuration: URL?
    /// A snapshot from `ipa-lint snapshot` to compare against, or nil to skip the baseline rules.
    package var baseline: URL?

    package init(input: URL, configuration: URL?, baseline: URL?) {
        self.input = input
        self.configuration = configuration
        self.baseline = baseline
    }
}
