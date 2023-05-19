extension ServerResource.Content
{
    @frozen public
    enum Payload:Equatable, Sendable
    {
        case binary([UInt8])
        case text(String)
    }
}
