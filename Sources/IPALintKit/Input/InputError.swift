/// Why an input path cannot be linted.
package enum InputError: Error, Equatable, Sendable, CustomStringConvertible {
    case notFound(String)
    case unsupportedType(String)
    case appNotFound(String)

    /// The message shown to the user.
    package var description: String {
        switch self {
        case let .notFound(path):
            "No file or directory at \(path)."
        case let .unsupportedType(path):
            "\(path) is not an .ipa, .xcarchive, or .app. Pass one of those."
        case let .appNotFound(path):
            "\(path) does not contain an .app bundle where one is expected (Payload/ or Products/Applications/)."
        }
    }
}
