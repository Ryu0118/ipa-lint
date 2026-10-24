/// Why a configuration file cannot be used.
package enum ConfigurationError: Error, Equatable, Sendable, CustomStringConvertible {
    case unreadable(String)
    case invalid(path: String, detail: String)
    case unknownRule(String)
    case missingReason(String)

    /// The message shown to the user.
    package var description: String {
        switch self {
        case let .unreadable(path):
            "Cannot read the configuration file at \(path)."
        case let .invalid(path, detail):
            "The configuration file at \(path) is not valid: \(detail)"
        case let .unknownRule(id):
            "The configuration names an unknown rule '\(id)'. Run `ipa-lint rules` for the list."
        case let .missingReason(pattern):
            "The allow entry for '\(pattern)' has no reason. Write why the file must ship."
        }
    }
}
