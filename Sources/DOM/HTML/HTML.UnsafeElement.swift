extension HTML
{
    @frozen public
    enum UnsafeElement:String, Equatable, Hashable, Sendable
    {
        case script
        case style
    }
}
