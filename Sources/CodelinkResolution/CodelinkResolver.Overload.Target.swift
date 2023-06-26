extension CodelinkResolver.Overload
{
    @frozen public
    enum Target:Equatable, Hashable
    {
        case scalar(Scalar)
        case vector(Scalar, self:Scalar)
    }
}
extension CodelinkResolver.Overload.Target:Sendable where Scalar:Sendable
{
}
