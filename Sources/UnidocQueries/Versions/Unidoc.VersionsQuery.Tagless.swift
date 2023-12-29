import UnidocRecords

extension Unidoc.VersionsQuery
{
    @frozen public
    struct Tagless:Equatable, Sendable
    {
        public
        var volume:Unidoc.VolumeMetadata?
        public
        var graph:Graph

        @inlinable public
        init(
            volume:Unidoc.VolumeMetadata?,
            graph:Graph)
        {
            self.volume = volume
            self.graph = graph
        }
    }
}
