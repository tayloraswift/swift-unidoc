import FNV1
import Symbols
import Unidoc
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct ForeignVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let extendee:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]

        //  Do we actually need this?
        public
        let flags:Phylum.DeclFlags

        public
        let stem:Unidoc.Stem
        public
        let hash:FNV24.Extended

        @inlinable public
        init(id:Unidoc.Scalar,
            extendee:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            flags:Phylum.DeclFlags,
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
extension Unidoc.ForeignVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var route:Unidoc.Route
    {
        .init(shoot: self.shoot, cdecl: self.flags.cdecl)
    }

    @inlinable public
    var shoot:Unidoc.Shoot
    {
        .init(
            stem: self.stem,
            hash: self.flags.route.hashed ? .init(truncating: self.hash) : nil)
    }

    @inlinable public
    var bias:Unidoc.Bias { .neutral }

    @inlinable public
    var decl:Phylum.DeclFlags? { self.flags }
}
extension Unidoc.ForeignVertex
{
    @inlinable public
    var overview:Unidoc.Passage? { nil }

    @inlinable public
    var details:Unidoc.Passage? { nil }

    @inlinable public
    var phylum:Phylum.Decl { self.flags.phylum }

    @inlinable public
    var kinks:Phylum.Decl.Kinks { self.flags.kinks }
}
