import Foundation

/// A property-list value in a `Sendable`, comparable form.
package indirect enum PlistValue: Equatable, Sendable {
    case string(String)
    case bool(Bool)
    case integer(Int)
    case real(Double)
    case date(Date)
    case data(Data)
    case array([PlistValue])
    case dictionary([String: PlistValue])

    /// The value when it is a boolean.
    package var boolValue: Bool? {
        if case let .bool(value) = self {
            return value
        }
        return nil
    }

    /// The value when it is a string.
    package var stringValue: String? {
        if case let .string(value) = self {
            return value
        }
        return nil
    }

    /// The value when it is a dictionary.
    package var dictionaryValue: [String: PlistValue]? {
        if case let .dictionary(value) = self {
            return value
        }
        return nil
    }
}
