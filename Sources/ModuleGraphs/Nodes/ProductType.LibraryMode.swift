extension ProductType
{
    @frozen public
    enum LibraryMode:String, Hashable, Equatable, Sendable
    {
        case automatic
        case dynamic
        case `static`
    }
}
