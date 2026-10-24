import Foundation
@testable import IPALintKit

/// Returns fixed entitlements per bundle path, relative to the app ("" for the app itself).
struct StubEntitlementsReader: EntitlementsReading {
    let appURL: URL
    let entitlements: [String: Data]

    init(appURL: URL, entitlements: [String: [String: Any]]) {
        self.appURL = appURL
        self.entitlements = entitlements.compactMapValues {
            try? PropertyListSerialization.data(fromPropertyList: $0, format: .xml, options: 0)
        }
    }

    func entitlementsData(ofBundleAt bundle: URL) async throws -> Data? {
        let appPath = appURL.standardizedFileURL.path(percentEncoded: false)
        let bundlePath = bundle.standardizedFileURL.path(percentEncoded: false)
        let relative = String(bundlePath.dropFirst(appPath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return entitlements[relative]
    }
}
