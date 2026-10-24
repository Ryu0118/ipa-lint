import Foundation

/// Encodes as plain JSON (dates as ISO 8601 strings, data as Base64) so snapshots stay readable.
extension PlistValue: Codable {
    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self = .integer(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .real(value)
            return
        }
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        if let value = try? container.decode([PlistValue].self) {
            self = .array(value)
            return
        }
        self = try .dictionary(container.decode([String: PlistValue].self))
    }

    /// Writes the value as the matching JSON type.
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .integer(value): try container.encode(value)
        case let .real(value): try container.encode(value)
        case let .date(value): try container.encode(value.ISO8601Format())
        case let .data(value): try container.encode(value.base64EncodedString())
        case let .array(value): try container.encode(value)
        case let .dictionary(value): try container.encode(value)
        }
    }
}
