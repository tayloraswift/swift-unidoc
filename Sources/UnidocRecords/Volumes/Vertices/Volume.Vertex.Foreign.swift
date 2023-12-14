import FNV1
import Unidoc

extension Unidoc.Vertex
{
    @frozen public
    struct Foreign:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let extendee:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]
        public
        let flags:Unidoc.Decl.Flags

        public
        let stem:Unidoc.Stem
        public
        let hash:FNV24.Extended

        @inlinable public
        init(id:Unidoc.Scalar,
            extendee:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            flags:Unidoc.Decl.Flags,
            stem:Unidoc.Stem,
            hash:FNV24.Extended)
        {
            self.id = id
            self.extendee = extendee
            self.scope = scope
            self.flags = flags
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Unidoc.Vertex.Foreign
{
    @inlinable public
    var phylum:Unidoc.Decl { self.flags.phylum }

    @inlinable public
    var kinks:Unidoc.Decl.Kinks { self.flags.kinks }

    @inlinable public
    var shoot:Unidoc.Shoot
    {
        .init(
            stem: self.stem,
            hash: self.flags.route == .hashed ? .init(truncating: self.hash) : nil)
    }
}
