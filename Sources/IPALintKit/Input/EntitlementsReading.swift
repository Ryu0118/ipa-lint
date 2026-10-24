import Foundation

/// Reads the code-signing entitlements of a signed bundle.
package protocol EntitlementsReading: Sendable {
    /// Returns the entitlements property list of the bundle at `bundle`, or nil when it carries none.
    func entitlementsData(ofBundleAt bundle: URL) async throws -> Data?
}
