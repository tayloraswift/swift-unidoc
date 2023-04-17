extension Repository
{
    @frozen public 
    struct Revision:Hashable, Equatable, Sendable
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
}
extension Repository.Revision:LosslessStringConvertible, CustomStringConvertible
{
}
