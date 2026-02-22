extension Unidoc {
    @frozen public struct RegistrarAccessMechanisms: Equatable, Sendable {
        public let githubInstallation: Int32?

        @inlinable public init(githubInstallation: Int32? = nil) {
            self.githubInstallation = githubInstallation
        }
    }
}
