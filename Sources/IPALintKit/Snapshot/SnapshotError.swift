/// Why a baseline snapshot cannot be used.
package enum SnapshotError: Error, Equatable, Sendable, CustomStringConvertible {
    case unreadable(String)
    case invalid(path: String, detail: String)

    /// The message shown to the user.
    package var description: String {
        switch self {
        case let .unreadable(path):
            "Cannot read the baseline snapshot at \(path)."
        case let .invalid(path, detail):
            "The baseline snapshot at \(path) is not valid JSON from `ipa-lint snapshot`: \(detail)"
        }
    }
}
