extension Unidoc {
    struct VolumeContext: Sendable {
        let principal: Unidoc.VolumeMetadata
        private(set) var secondary: [Unidoc.Edition: Unidoc.VolumeMetadata]

        private init(
            principal: Unidoc.VolumeMetadata,
            secondary: [Unidoc.Edition: Unidoc.VolumeMetadata]
        ) {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension Unidoc.VolumeContext {
    init(principal: Unidoc.VolumeMetadata, secondary: borrowing [Unidoc.VolumeMetadata] = []) {
        let secondary: [Unidoc.Edition: Unidoc.VolumeMetadata] = secondary.reduce(into: [:]) {
            $0[$1.id] = principal.id != $1.id ? $1 : nil
        }
        self.init(principal: principal, secondary: secondary)
    }
}
extension Unidoc.VolumeContext {
    subscript(id: Unidoc.Edition) -> Unidoc.VolumeMetadata? {
        self.principal.id == id ? self.principal : self.secondary[id]
    }
}
