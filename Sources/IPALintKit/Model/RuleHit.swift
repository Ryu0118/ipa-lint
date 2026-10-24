/// One problem a rule found, before the configuration decides its severity and whether it is allowed.
package struct RuleHit: Equatable, Sendable {
    /// The path inside the app, relative to the `.app` directory.
    package var path: String
    /// What is wrong and how to fix it.
    package var message: String

    package init(path: String, message: String) {
        self.path = path
        self.message = message
    }
}
