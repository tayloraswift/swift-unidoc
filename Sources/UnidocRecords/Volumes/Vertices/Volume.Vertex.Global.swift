import Unidoc

extension Volume.Vertex
{
    @frozen public
    struct Global:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        var snapshot:Volume.SnapshotDetails

        @inlinable public
        init(id:Unidoc.Scalar, snapshot:Volume.SnapshotDetails)
        {
            self.id = id
            self.snapshot = snapshot
        }
    }
}
