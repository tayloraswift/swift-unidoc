import FNV1
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct GlobalVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        var snapshot:Unidoc.SnapshotDetails

        @inlinable public
        init(id:Unidoc.Scalar, snapshot:Unidoc.SnapshotDetails)
        {
            self.id = id
            self.snapshot = snapshot
        }
    }
}
extension Unidoc.GlobalVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var stem:Unidoc.Stem { "" }

    //  This must have a value, otherwise it would get lost among all the file
    //  vertices, and queries for it would be very slow.
    @inlinable public
    var hash:FNV24.Extended { .init(rawValue: 0) }
}
