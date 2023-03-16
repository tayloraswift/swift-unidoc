@frozen public 
struct GitRevision:Hashable, Equatable, Sendable
{
    //  TODO: find a better representation for this.
    public
    let description:String

    @inlinable public
    init(_ description:String)
    {
        self.description = description
    }
}
extension GitRevision:LosslessStringConvertible, CustomStringConvertible
{
}
