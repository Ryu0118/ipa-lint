import Foundation

/// A glob that matches paths inside the app.
///
/// A pattern without `/` matches the file name anywhere in the app. A pattern with `/` matches the whole path from
/// the `.app` directory, and its `*` also matches across `/`.
package struct PathPattern: Decodable, Equatable, Sendable {
    /// The glob as written in the configuration.
    package var pattern: String

    package init(_ pattern: String) {
        self.pattern = pattern
    }

    package init(from decoder: any Decoder) throws {
        pattern = try decoder.singleValueContainer().decode(String.self)
    }

    /// Whether `path` (relative to the `.app` directory) matches the pattern.
    package func matches(_ path: String) -> Bool {
        let subject = pattern.contains("/") ? path : String(path.split(separator: "/").last ?? Substring(path))
        return fnmatch(pattern, subject, 0) == 0
    }
}
