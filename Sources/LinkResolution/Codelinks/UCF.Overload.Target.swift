import UCF

extension UCF.Overload
{
    @frozen public
    enum Target:Equatable, Hashable
    {
        case scalar(Scalar)
        case vector(Scalar, self:Scalar)
    }
}
extension UCF.Overload.Target:Sendable where Scalar:Sendable
{
}
