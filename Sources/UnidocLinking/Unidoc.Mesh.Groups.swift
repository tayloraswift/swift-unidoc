import UnidocRecords

extension Unidoc.Mesh {
    @frozen public struct Groups: Sendable {
        public var conformers: [Unidoc.ConformerGroup]
        public var extensions: [Unidoc.ExtensionGroup]
        public var intrinsics: [Unidoc.IntrinsicGroup]
        public var curators: [Unidoc.CuratorGroup]

        @inlinable public init(
            conformers: [Unidoc.ConformerGroup] = [],
            extensions: [Unidoc.ExtensionGroup] = [],
            intrinsics: [Unidoc.IntrinsicGroup] = [],
            curators: [Unidoc.CuratorGroup] = []
        ) {
            self.conformers = conformers
            self.extensions = extensions
            self.intrinsics = intrinsics
            self.curators = curators
        }
    }
}
