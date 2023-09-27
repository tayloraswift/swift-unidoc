extension Volume
{
    @frozen public
    struct Range:Equatable, Hashable, Sendable
    {
        public
        let min:Volume.Meta.CodingKey
        public
        let max:Volume.Meta.CodingKey

        @inlinable internal
        init(min:Volume.Meta.CodingKey, max:Volume.Meta.CodingKey)
        {
            self.min = min
            self.max = max
        }
    }
}
extension Volume.Range
{
    /// Matches the ``UnidocPlane article`` plane only.
    @inlinable public static
    var articles:Self { .init(min: .planes_article, max: .planes_file) }

    /// Matches the ``UnidocPlane file`` plane only.
    @inlinable public static
    var files:Self { .init(min: .planes_file, max: .planes_extension) }
}
