extension CodelinkResolver
{
    @frozen public
    enum Target:Equatable, Hashable, Sendable
    {
        case scalar     (UInt32)
        case compound   (UInt32, self:UInt32)
    }
}
