import FNV1
import Symbols
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct LandingVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        var snapshot:Unidoc.SnapshotDetails
        public
        var packages:[Unidoc.Package]

        @inlinable public
        init(id:Unidoc.Scalar, snapshot:Unidoc.SnapshotDetails, packages:[Unidoc.Package])
        {
            self.id = id
            self.snapshot = snapshot
            self.packages = packages
        }
    }
}
extension Unidoc.LandingVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var overview:Unidoc.Passage? { nil }

    @inlinable public
    var details:Unidoc.Passage? { nil }

    @inlinable public
    var stem:Unidoc.Stem { "" }

    //  This must have a value, otherwise it would get lost among all the file
    //  vertices, and queries for it would be very slow.
    @inlinable public
    var hash:FNV24.Extended { .init(rawValue: 0) }

    @inlinable public
    var bias:Unidoc.Bias { .package }

    @inlinable public
    var decl:Phylum.DeclFlags? { nil }
}
