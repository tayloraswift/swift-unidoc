extension SearchIndexQuery.Output
{
    @frozen public
    enum Content:Sendable
    {
        case binary([UInt8])
        case length(Int)
    }
}
