import Foundation

package extension PlistValue {
    /// Converts an object produced by `PropertyListSerialization`; nil for types a property list cannot hold.
    init?(propertyListObject object: Any) {
        switch object {
        case let number as NSNumber:
            self = Self(number: number)
        case let string as String:
            self = .string(string)
        case let date as Date:
            self = .date(date)
        case let data as Data:
            self = .data(data)
        case let array as [Any]:
            self = .array(array.compactMap(PlistValue.init(propertyListObject:)))
        case let dictionary as [String: Any]:
            self = .dictionary(dictionary.compactMapValues(PlistValue.init(propertyListObject:)))
        default:
            return nil
        }
    }

    /// Decodes property-list data (XML or binary) whose root is a dictionary.
    static func dictionary(from data: Data) -> [String: PlistValue]? {
        let object = try? PropertyListSerialization.propertyList(from: data, format: nil)
        return object.flatMap(PlistValue.init(propertyListObject:))?.dictionaryValue
    }

    private init(number: NSNumber) {
        // NSNumber bridges booleans too; only the CFBoolean type ID tells them apart from 0 and 1.
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            self = .bool(number.boolValue)
        } else if CFNumberIsFloatType(number) {
            self = .real(number.doubleValue)
        } else {
            self = .integer(number.intValue)
        }
    }
}
