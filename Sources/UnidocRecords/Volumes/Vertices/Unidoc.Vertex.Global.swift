import Unidoc

extension Unidoc.Vertex
{
    @frozen public
    struct Global:Identifiable, Equatable, Sendable
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
