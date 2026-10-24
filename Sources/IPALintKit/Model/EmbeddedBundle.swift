/// A bundle inside the app (the app itself, an extension, a framework, or a watch app) with its metadata.
package struct EmbeddedBundle: Equatable, Sendable {
    /// The bundle directory relative to the `.app` directory; empty for the app itself.
    package var path: String
    /// What kind of bundle it is.
    package var kind: BundleKind
    /// The decoded `Info.plist`.
    package var infoPlist: [String: PlistValue]
    /// The code-signing entitlements; empty for frameworks and unsigned bundles.
    package var entitlements: [String: PlistValue]

    /// The path to show for the bundle itself: its directory, or `.` for the app.
    package var displayPath: String {
        path.isEmpty ? "." : path
    }

    package init(path: String, kind: BundleKind, infoPlist: [String: PlistValue], entitlements: [String: PlistValue]) {
        self.path = path
        self.kind = kind
        self.infoPlist = infoPlist
        self.entitlements = entitlements
    }

    /// The path of `name` inside this bundle, relative to the `.app` directory.
    package func childPath(_ name: String) -> String {
        path.isEmpty ? name : "\(path)/\(name)"
    }
}
