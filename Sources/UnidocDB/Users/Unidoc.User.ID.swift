import BSON
import UnidocRecords

extension Unidoc.User
{
    @frozen public
    enum ID:Equatable, Hashable, Sendable
    {
        case machine(Int32)
        case github(Int32)
    }
}
extension Unidoc.User.ID:RawRepresentable
{
    @inlinable public
    init?(rawValue:Int64)
    {
        let scalar:Int32 = .init(truncatingIfNeeded: rawValue)

        switch Unidoc.User.AccountType.init(rawValue: rawValue >> 32)
        {
        case .machine?: self = .machine(scalar)
        case .github?:  self = .github(scalar)
        case nil:       return nil
        }
    }

    @inlinable public
    var rawValue:Int64
    {
        switch self
        {
        case .machine(let scalar): Unidoc.User.AccountType.machine[scalar]
        case .github(let scalar):  Unidoc.User.AccountType.github[scalar]
        }
    }
}
extension Unidoc.User.ID:BSONDecodable, BSONEncodable
{
}
extension Unidoc.User.ID:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(UInt64.init(bitPattern: self.rawValue))"
    }
}
extension Unidoc.User.ID:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let value:UInt64 = .init(description),
            let value:Self = .init(rawValue: .init(bitPattern: value))
        {
            self = value
        }
        else
        {
            return nil
        }
    }
}
