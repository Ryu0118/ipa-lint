/// A finding that an `allow` entry of the configuration suppressed.
package struct SuppressedFinding: Codable, Equatable, Sendable {
    /// The finding that would have been reported.
    package var finding: Finding
    /// The reason the `allow` entry gives for keeping the file.
    package var reason: String

    package init(finding: Finding, reason: String) {
        self.finding = finding
        self.reason = reason
    }
}
