/// A command-line tool the CLI delegates to failed.
package enum ToolError: Error, Equatable, Sendable, CustomStringConvertible {
    case failed(tool: String, status: String, message: String)

    /// The message shown to the user.
    package var description: String {
        switch self {
        case let .failed(tool, status, message):
            "\(tool) failed (\(status)): \(message)"
        }
    }
}
