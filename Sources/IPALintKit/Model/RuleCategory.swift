/// The group a rule belongs to.
package enum RuleCategory: String, Codable, Sendable, CaseIterable {
    /// Files that only add size to the download.
    case waste
    /// Settings or contents that leak data or weaken the app's security.
    case security
    /// Problems that App Store review or the OS rejects.
    case review
    /// Changes against a baseline snapshot of a previous build.
    case baseline
}
