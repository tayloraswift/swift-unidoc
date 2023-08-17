import SHA1

extension Repository
{
    @frozen public
    enum Revision:Equatable, Hashable, Sendable
    {
        case sha1(SHA1)
    }
}
extension Repository.Revision:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .sha1(let hash):   return "\(hash)"
        }
    }
}
extension Repository.Revision:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
    @inlinable public
    init?(_ description:Substring)
    {
        if  let hash:SHA1 = .init(description)
        {
            self = .sha1(hash)
        }
        else
        {
            return nil
        }
    }
}
