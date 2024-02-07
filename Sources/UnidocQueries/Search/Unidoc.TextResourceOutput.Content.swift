extension Unidoc.TextResourceOutput
{
    @frozen public
    enum Content:Sendable
    {
        case binary([UInt8])
        case length(Int)
    }
}
