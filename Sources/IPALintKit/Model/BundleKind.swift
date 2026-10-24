/// The kind of a bundle nested in the app, derived from its directory extension.
package enum BundleKind: String, Codable, Sendable {
    case application
    case appExtension
    case framework

    /// The kind for a directory name such as `Foo.appex`, or nil when it is not a bundle this tool inspects.
    package init?(directoryName: String) {
        switch directoryName.split(separator: ".").last {
        case "app": self = .application
        case "appex": self = .appExtension
        case "framework": self = .framework
        default: return nil
        }
    }
}
