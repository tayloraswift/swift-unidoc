extension Unidoc
{
    @frozen public
    struct VolumeRange:Equatable, Hashable, Sendable
    {
        public
        let min:Unidoc.VolumeMetadata.CodingKey
        public
        let max:Unidoc.VolumeMetadata.CodingKey

        @inlinable internal
        init(min:Unidoc.VolumeMetadata.CodingKey, max:Unidoc.VolumeMetadata.CodingKey)
        {
            self.min = min
            self.max = max
        }
    }
}
