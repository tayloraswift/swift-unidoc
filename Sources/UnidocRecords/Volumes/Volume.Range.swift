extension Volume
{
    @frozen public
    struct Range:Equatable, Hashable, Sendable
    {
        public
        let min:Volume.Metadata.CodingKey
        public
        let max:Volume.Metadata.CodingKey

        @inlinable internal
        init(min:Volume.Metadata.CodingKey, max:Volume.Metadata.CodingKey)
        {
            self.min = min
            self.max = max
        }
    }
}
extension Volume.Range
{
    /// Matches the ``SymbolGraph.Plane/article`` plane only.
    @inlinable public static
    var articles:Self { .init(min: .planes_article, max: .planes_file) }

    /// Matches the ``SymbolGraph.Plane/file`` plane only.
    @inlinable public static
    var files:Self { .init(min: .planes_file, max: .planes_extension) }
}
