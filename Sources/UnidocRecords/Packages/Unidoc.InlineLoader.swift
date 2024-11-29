extension Unidoc
{
    /// A ``GraphLoader`` that can only load inline symbol graphs.
    @frozen public
    struct InlineLoader:GraphLoader
    {
        @inlinable
        init() {}

        public
        func load(graph:GraphPath) async throws -> ArraySlice<UInt8>
        {
            throw InlineLoaderError.init(path: graph)
        }
    }
}
